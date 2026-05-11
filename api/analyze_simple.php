<?php
// 簡化版本的 analyze.php 用於調試

// 錯誤報告設置
error_reporting(E_ALL);
ini_set('display_errors', 0); // 不顯示錯誤到瀏覽器
ini_set('log_errors', 1);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

try {
    // 檢查請求方法
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('只允許 POST 請求');
    }
    
    // 檢查配置文件
    $configPath = __DIR__ . '/../env.php';
    if (!file_exists($configPath)) {
        throw new Exception('配置文件不存在: ' . $configPath);
    }
    
    $config = include($configPath);
    if (!$config || !isset($config['GEMINI_API_KEY'])) {
        throw new Exception('配置載入失敗或缺少 GEMINI_API_KEY');
    }
    
    // 檢查上傳文件
    if (!isset($_FILES['image'])) {
        throw new Exception('沒有上傳圖片文件');
    }
    
    if ($_FILES['image']['error'] !== UPLOAD_ERR_OK) {
        throw new Exception('文件上傳錯誤: ' . $_FILES['image']['error']);
    }
    
    // 模擬成功回應
    $mockResponse = [
        'success' => true,
        'data' => [
            'items' => [
                [
                    'id' => 'test_' . time(),
                    'name' => 'apple',
                    'grams' => 150
                ]
            ],
            'total_items' => 1,
            'processed_at' => date('Y-m-d H:i:s'),
            'debug' => [
                'config_loaded' => true,
                'gemini_key_exists' => !empty($config['GEMINI_API_KEY']),
                'file_uploaded' => true,
                'file_size' => $_FILES['image']['size'],
                'file_type' => $_FILES['image']['type']
            ]
        ]
    ];
    
    echo json_encode($mockResponse);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'debug' => [
            'php_version' => PHP_VERSION,
            'request_method' => $_SERVER['REQUEST_METHOD'] ?? 'unknown',
            'config_path' => $configPath ?? 'unknown',
            'config_exists' => file_exists($configPath ?? ''),
            'files_received' => array_keys($_FILES),
            'post_data' => array_keys($_POST)
        ]
    ]);
}
?>
