<?php
/**
 * Fooda 會員系統API端點
 * 處理會員相關的所有API請求
 */

// 清理輸出緩衝區，確保沒有之前的輸出
if (ob_get_level()) {
    ob_clean();
}

// 禁用錯誤輸出到瀏覽器
ini_set('display_errors', 0);
error_reporting(0);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 處理 OPTIONS 請求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../membership_manager.php';

$membershipManager = new MembershipManager();
$action = $_GET['action'] ?? $_POST['action'] ?? '';

try {
    switch ($action) {
        case 'get_membership_info':
            // 獲取用戶會員資訊
            $info = $membershipManager->getMembershipInfo();
            echo json_encode([
                'success' => true,
                'data' => $info
            ]);
            break;
            
        case 'check_feature_access':
            // 檢查功能權限
            $feature = $_GET['feature'] ?? $_POST['feature'] ?? '';
            if (empty($feature)) {
                throw new Exception('功能名稱不能為空');
            }
            
            $hasAccess = $membershipManager->hasFeatureAccess($feature);
            $membershipManager->logFeatureUsage($feature, $hasAccess);
            
            echo json_encode([
                'success' => true,
                'has_access' => $hasAccess,
                'restriction_message' => $hasAccess ? null : $membershipManager->getRestrictionMessage('ai_recognition_blocked')
            ]);
            break;
            
        case 'check_ai_quota':
            // 檢查AI識別額度
            $hasQuota = $membershipManager->hasAIQuota();
            $remaining = $membershipManager->getRemainingAIQuota();
            
            echo json_encode([
                'success' => true,
                'has_quota' => $hasQuota,
                'remaining_quota' => $remaining,
                'quota_info' => $membershipManager->getMembershipInfo()['ai_quota']
            ]);
            break;
            
        case 'consume_ai_quota':
            // 消耗AI識別額度
            $success = $membershipManager->consumeAIQuota();
            $remaining = $membershipManager->getRemainingAIQuota();
            
            echo json_encode([
                'success' => $success,
                'remaining_quota' => $remaining,
                'message' => $success ? '額度消耗成功' : '額度不足'
            ]);
            break;
            
        case 'get_upgrade_options':
            // 獲取升級方案
            $upgrades = $membershipManager->getAvailableUpgrades();
            
            echo json_encode([
                'success' => true,
                'upgrade_options' => $upgrades
            ]);
            break;
            
        case 'get_credit_packages':
            // 獲取加購點數方案
            $packages = $membershipManager->getCreditPackages();
            
            echo json_encode([
                'success' => true,
                'credit_packages' => $packages
            ]);
            break;
            
        case 'purchase_credits':
            // 購買額外點數
            $packageId = $_POST['package_id'] ?? '';
            if (empty($packageId)) {
                throw new Exception('請選擇點數包');
            }
            
            $result = $membershipManager->purchaseCredits($packageId);
            echo json_encode($result);
            break;
            
        case 'upgrade_membership':
            // 升級會員（開發階段模擬）
            $newLevel = $_POST['level'] ?? '';
            if (empty($newLevel)) {
                throw new Exception('請選擇會員等級');
            }
            
            $success = $membershipManager->setMembershipLevel($newLevel);
            if ($success) {
                echo json_encode([
                    'success' => true,
                    'message' => '會員升級成功！',
                    'new_membership_info' => $membershipManager->getMembershipInfo()
                ]);
            } else {
                throw new Exception('無效的會員等級');
            }
            break;
            
        case 'get_development_plans':
            // 獲取開發階段可切換的方案
            $plans = $membershipManager->getAvailablePlansForDevelopment();
            
            echo json_encode([
                'success' => true,
                'available_plans' => $plans,
                'current_plan' => $membershipManager->getMembershipInfo()['level']
            ]);
            break;
            
        case 'should_show_ads':
            // 檢查是否應該顯示廣告
            $showAds = $membershipManager->shouldShowAds();
            
            echo json_encode([
                'success' => true,
                'show_ads' => $showAds
            ]);
            break;
            
        case 'get_restriction_message':
            // 獲取功能限制消息
            $messageKey = $_GET['message_key'] ?? $_POST['message_key'] ?? '';
            $language = $_GET['language'] ?? $_POST['language'] ?? 'zh-TW';
            
            if (empty($messageKey)) {
                throw new Exception('消息鍵值不能為空');
            }
            
            $message = $membershipManager->getRestrictionMessage($messageKey, $language);
            
            echo json_encode([
                'success' => true,
                'message' => $message
            ]);
            break;
            
        default:
            throw new Exception('無效的操作');
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
