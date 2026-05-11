import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/ad_service.dart';
import '../membership/providers/membership_provider.dart';


class DebugAdTestScreen extends StatefulWidget {
  const DebugAdTestScreen({super.key});

  @override
  State<DebugAdTestScreen> createState() => _DebugAdTestScreenState();
}

class _DebugAdTestScreenState extends State<DebugAdTestScreen> {
  String _status = 'Ready';

  void _updateStatus(String status) {
    if (mounted) {
      setState(() {
        _status = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final membership = Provider.of<MembershipProvider>(context);
    final adService = AdService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AdMob Debug'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: $_status', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('Show Ads: ${membership.showAds}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Membership Tier: ${membership.tier}'),
                    Text('Reward Points: ${membership.remainingAiQuota} (Quota)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Toggles
            SwitchListTile(
              title: const Text('Force Remove Ads'),
              subtitle: const Text('Simulate Premium behavior'),
              value: !membership.showAds && membership.tier == MembershipTier.free, // Logic might be complex, simpler to use internal flag if exposed
              // But we only have debugSetRemoveAds. let's assume if it is removed, switch is ON.
              // Actually we don't have public getter for _removeAds. We infer from showAds.
              // If free tier and !showAds => Removed.
              onChanged: (val) {
                membership.debugSetRemoveAds(val);
                _updateStatus('Remove Ads set to $val');
              },
            ),

            // const Divider(),
            // const Text('Banner Ad', style: TextStyle(fontWeight: FontWeight.bold)),
            // const SizedBox(height: 8),
            // // Banner is automatically shown based on showAds
            // const SizedBox(
            //   height: 60,
            //   child: BannerAdWidget(),
            // ),
            // const SizedBox(height: 16),

            const Divider(),
            const Text('Interstitial Ad', style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () async {
                _updateStatus('Loading Interstitial...');
                // Force load
                await adService.loadInterstitial();
                _updateStatus('Interstitial Loaded. Showing...');
                adService.showInterstitial(onAdClosed: () {
                  _updateStatus('Interstitial Closed');
                });
              },
              child: const Text('Load & Show Interstitial'),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const Text('Rewarded Ad', style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () async {
                _updateStatus('Loading Rewarded...');
                await adService.loadRewarded();
                _updateStatus('Rewarded Loaded. Showing...');
                adService.showRewarded(
                  onUserEarnedReward: (reward) {
                    membership.addRewardPoints(1);
                    _updateStatus('Reward Earned: 1');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reward Earned: 1')),
                    );
                  },
                  onAdClosed: () {
                    _updateStatus('Rewarded Closed');
                  },
                );
              },
              child: const Text('Load & Show Rewarded'),
            ),
          ],
        ),
      ),
    );
  }
}
