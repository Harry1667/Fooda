<?php
/**
 * Fooda 營養查詢 API
 * 根據規格文件實現 - 使用 USDA FoodData Central API
 */

// 設定錯誤報告
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

// 修正 Mac 上的檔案上傳限制問題
ini_set('memory_limit', '256M');
ini_set('max_execution_time', '120');

// 設定 headers
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// 載入配置
$config = include(__DIR__ . '/../env.php');
if (!$config) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Configuration load failed',
        'code' => 'CONFIG_ERROR'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * 統一錯誤回應函數
 */
function sendError($message, $code, $httpCode = 400) {
    http_response_code($httpCode);
    echo json_encode([
        'success' => false,
        'error' => $message,
        'code' => $code
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * 成功回應函數
 */
function sendSuccess($data) {
    echo json_encode([
        'success' => true,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * 營養素映射
 */
function mapNutrients($nutrients) {
    $mapped = [
        'kcal' => 0,
        'carb' => 0,
        'protein' => 0,
        'fat' => 0,
        'fiber' => 0,
        'sodium' => 0
    ];
    
    foreach ($nutrients as $nutrient) {
        // 嘗試多種可能的數據結構
        $nutrientNumber = '';
        $amount = 0;
        $unitName = '';
        
        // 檢查不同的數據結構
        if (isset($nutrient['nutrient']['number'])) {
            // 標準結構
            $nutrientNumber = strval($nutrient['nutrient']['number']);
            $amount = floatval($nutrient['amount'] ?? 0);
            $unitName = $nutrient['nutrient']['unitName'] ?? '';
        } elseif (isset($nutrient['nutrientNumber'])) {
            // 替代結構 1
            $nutrientNumber = strval($nutrient['nutrientNumber']);
            $amount = floatval($nutrient['value'] ?? $nutrient['amount'] ?? 0);
            $unitName = $nutrient['unitName'] ?? '';
        } elseif (isset($nutrient['id'])) {
            // 替代結構 2
            $nutrientNumber = strval($nutrient['id']);
            $amount = floatval($nutrient['amount'] ?? $nutrient['value'] ?? 0);
            $unitName = $nutrient['unit'] ?? $nutrient['unitName'] ?? '';
        }
        
        // 記錄調試信息
        error_log("處理營養素: number={$nutrientNumber}, amount={$amount}, unit={$unitName}");
        
        // 根據 nutrientNumber 映射到我們的營養素
        $nutrientMapping = [
            '208' => 'kcal',     // Energy (kcal)
            '268' => 'kcal',     // Energy (kJ) - 需要轉換
            '269' => 'kcal',     // Energy
            '205' => 'carb',     // Carbohydrate, by difference
            '203' => 'protein',  // Protein
            '204' => 'fat',      // Total lipid (fat)
            '291' => 'fiber',    // Fiber, total dietary
            '307' => 'sodium',   // Sodium, Na
            '301' => 'sodium',   // Sodium (alternative)
        ];
        
        if (isset($nutrientMapping[$nutrientNumber]) && $amount > 0) {
            $targetNutrient = $nutrientMapping[$nutrientNumber];
            $value = $amount;
            
            // 單位轉換
            if ($nutrientNumber === '268' && stripos($unitName, 'kj') !== false) {
                // kJ 轉換為 kcal
                $value = $amount / 4.184;
            } elseif ($targetNutrient === 'sodium' && stripos($unitName, 'mg') !== false) {
                // mg 轉換為 g (sodium 通常以 mg 為單位)
                $value = $amount / 1000;
            }
            
            // 只有當新值大於現有值時才更新（選擇最準確的數據）
            if ($value > $mapped[$targetNutrient]) {
                $mapped[$targetNutrient] = round($value, 1);
            }
        }
    }
    
    // 記錄最終映射結果
    error_log("營養素映射結果: " . json_encode($mapped, JSON_UNESCAPED_UNICODE));
    
    return $mapped;
}

try {
    // 1. 驗證請求方法
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        sendError('Only POST method allowed', $config['ERROR_CODES']['USDA_BAD_PARAMS'], 405);
    }

    // 2. 取得請求參數
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) {
        // 支援 form data
        $input = $_POST;
    }

    $name = trim($input['name'] ?? '');
    $grams = floatval($input['grams'] ?? 0);

    // 3. 驗證參數
    if (empty($name)) {
        sendError('Food name is required', $config['ERROR_CODES']['USDA_BAD_PARAMS'], 400);
    }

    if ($grams <= 0) {
        sendError('Grams must be greater than 0', $config['ERROR_CODES']['USDA_BAD_PARAMS'], 400);
    }

    // 4. 搜尋食物
    $searchUrl = $config['USDA_SEARCH_URL'] . '?' . http_build_query([
        'query' => $name,
        'pageSize' => $config['USDA_CONFIG']['pageSize'],
        'api_key' => $config['USDA_API_KEY']
    ]);

    $ch = curl_init();
    curl_setopt_array($ch, [
        CURLOPT_URL => $searchUrl,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            'Content-Type: application/json',
            'User-Agent: Fooda/1.0'
        ],
        CURLOPT_TIMEOUT => 30,
        CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_SSL_VERIFYHOST => false,
        CURLOPT_FOLLOWLOCATION => true
    ]);

    $searchResponse = curl_exec($ch);
    $searchHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $searchError = curl_error($ch);
    curl_close($ch);

    // 5. 檢查搜尋錯誤
    if ($searchError) {
        error_log("USDA search cURL error: " . $searchError);
        sendError('USDA service request failed', $config['ERROR_CODES']['USDA_INTERNAL'], 500);
    }

    if ($searchHttpCode !== 200) {
        error_log("USDA search HTTP error: {$searchHttpCode} - {$searchResponse}");
        sendError("USDA service error: {$searchHttpCode}", $config['ERROR_CODES']['USDA_INTERNAL'], 500);
    }

    // 6. 解析搜尋結果
    $searchData = json_decode($searchResponse, true);
    if (!$searchData || !isset($searchData['foods']) || empty($searchData['foods'])) {
        sendError("Food '{$name}' not found in USDA database", $config['ERROR_CODES']['USDA_NOT_FOUND'], 404);
    }

    $food = $searchData['foods'][0];
    $fdcId = $food['fdcId'];
    $foundName = $food['description'] ?? $name;

    // 7. 取得詳細營養資料
    $detailUrl = $config['USDA_DETAIL_URL'] . '/' . $fdcId . '?' . http_build_query([
        'api_key' => $config['USDA_API_KEY']
    ]);

    $ch = curl_init();
    curl_setopt_array($ch, [
        CURLOPT_URL => $detailUrl,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            'Content-Type: application/json',
            'User-Agent: Fooda/1.0'
        ],
        CURLOPT_TIMEOUT => 30,
        CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_SSL_VERIFYHOST => false,
        CURLOPT_FOLLOWLOCATION => true
    ]);

    $detailResponse = curl_exec($ch);
    $detailHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $detailError = curl_error($ch);
    curl_close($ch);

    // 8. 檢查詳細資料錯誤
    if ($detailError) {
        error_log("USDA detail cURL error: " . $detailError);
        sendError('USDA detail service request failed', $config['ERROR_CODES']['USDA_INTERNAL'], 500);
    }

    if ($detailHttpCode !== 200) {
        error_log("USDA detail HTTP error: {$detailHttpCode} - {$detailResponse}");
        sendError("USDA detail service error: {$detailHttpCode}", $config['ERROR_CODES']['USDA_INTERNAL'], 500);
    }

    // 9. 解析營養資料
    $detailData = json_decode($detailResponse, true);
    if (!$detailData || !isset($detailData['foodNutrients'])) {
        sendError('Failed to get nutrition details', $config['ERROR_CODES']['USDA_INTERNAL'], 500);
    }

    // 10. 映射營養素（每100g）
    // 調試：記錄營養數據結構
    error_log("USDA 完整營養數據結構: " . json_encode($detailData['foodNutrients'], JSON_UNESCAPED_UNICODE));
    error_log("USDA 食物名稱: " . ($detailData['description'] ?? 'unknown'));
    error_log("USDA FDC ID: " . ($detailData['fdcId'] ?? 'unknown'));
    
    $per100g = mapNutrients($detailData['foodNutrients']);

    // 11. 計算實際份量的營養素
    $ratio = $grams / 100;
    $nutrition = [];
    foreach ($per100g as $key => $value) {
        $nutrition[$key] = round($value * $ratio, 1);
    }

    // 12. 記錄成功日誌
    error_log("Nutrition lookup success: {$name} -> {$foundName} ({$fdcId})");

    // 13. 回應成功結果
    sendSuccess([
        'name' => $name,
        'found_name' => $foundName,
        'grams' => $grams,
        'fdc_id' => $fdcId,
        'nutrition' => $nutrition,
        'per_100g' => $per100g,
        'source' => 'USDA_FDC',
        'calculated_at' => date('Y-m-d H:i:s')
    ]);

} catch (Exception $e) {
    error_log("nutrition.php Exception: " . $e->getMessage());
    sendError('Internal server error', $config['ERROR_CODES']['USDA_INTERNAL'], 500);
} catch (Error $e) {
    error_log("nutrition.php Error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
    sendError('Internal server error', $config['ERROR_CODES']['USDA_INTERNAL'], 500);
}
?>