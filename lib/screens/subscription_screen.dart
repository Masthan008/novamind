import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/subscription_service.dart';
import '../services/student_auth_service.dart';
import '../widgets/payment_dialog.dart';
import '../widgets/user_badge.dart';

/// Premium Subscription Plans Screen with stunning coral/orange theme
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> 
    with SingleTickerProviderStateMixin {
  bool _hasPendingRequest = false;
  late AnimationController _glowController;
  
  @override
  void initState() {
    super.initState();
    _checkPendingRequest();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }
  
  Future<void> _checkPendingRequest() async {
    final pending = await SubscriptionService.hasPendingRequest();
    if (mounted) {
      setState(() => _hasPendingRequest = pending);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTier = SubscriptionService.currentTier;
    final student = StudentAuthService.currentStudent;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.5),
                    radius: 1.5,
                    colors: [
                      const Color(0xFFFF6B6B).withOpacity(0.15 * _glowController.value),
                      const Color(0xFFFF8E53).withOpacity(0.1 * _glowController.value),
                      const Color(0xFF0A0A0F),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Main content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    ).createShader(bounds),
                    child: Text(
                      'Upgrade Your Plan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  centerTitle: true,
                ),
                
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Current Plan Card
                      if (student != null) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                currentTier.color.withOpacity(0.3),
                                Colors.grey.shade900.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: currentTier.color.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: currentTier.color.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      currentTier.color.withOpacity(0.3),
                                      currentTier.color.withOpacity(0.1),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: currentTier.color.withOpacity(0.5),
                                  ),
                                ),
                                child: Icon(currentTier.icon, color: currentTier.color, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Plan',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          currentTier.displayName.toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            color: currentTier.color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        UserBadge(tier: currentTier.displayName.toLowerCase(), compact: true),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.check_circle,
                                color: currentTier.color,
                                size: 28,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                        
                        const SizedBox(height: 24),
                      ],
                      
                      // Pending Request Banner
                      if (_hasPendingRequest) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.withOpacity(0.2),
                                Colors.orange.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.orange.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.hourglass_top, color: Colors.orange, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Upgrade Pending',
                                      style: GoogleFonts.poppins(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Please wait 1-2 hours for approval',
                                      style: GoogleFonts.poppins(
                                        color: Colors.orange.shade200,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .shimmer(duration: 2.seconds, color: Colors.orange.withOpacity(0.3)),
                        const SizedBox(height: 24),
                      ],
                      
                      // Section Header
                      Text(
                        'Choose Your Plan',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 6),
                      Text(
                        'Unlock premium features & exclusive content',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 20),
                      
                      // Plan Cards
                      _buildPlanCard(
                        tier: SubscriptionTier.free,
                        features: [
                          'Access to free books',
                          'Basic calculators',
                          'News feed',
                          '3 Free projects',
                        ],
                        lockedFeatures: [
                          'Pro/Ultra projects',
                          'Priority support',
                        ],
                        isCurrentPlan: currentTier == SubscriptionTier.free,
                        delay: 0,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildPlanCard(
                        tier: SubscriptionTier.pro,
                        features: [
                          'All Free features',
                          'Pro books unlocked',
                          '7 Pro projects (total 10)',
                          'Advanced tools',
                          'Pro badge',
                        ],
                        lockedFeatures: [
                          'Ultra content',
                        ],
                        isCurrentPlan: currentTier == SubscriptionTier.pro,
                        isRecommended: true,
                        delay: 100,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildPlanCard(
                        tier: SubscriptionTier.ultra,
                        features: [
                          'All Pro features',
                          'ALL books unlocked',
                          '5 Ultra projects (total 15)',
                          'Exclusive content',
                          'Ultra badge',
                          'Priority support',
                        ],
                        lockedFeatures: [],
                        isCurrentPlan: currentTier == SubscriptionTier.ultra,
                        delay: 200,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // How to upgrade section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B6B).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.help_outline, color: Color(0xFFFF6B6B), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'How to Upgrade',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildStep(1, 'Tap on Pro or Ultra plan'),
                            _buildStep(2, 'Scan QR code to pay via PhonePe/GPay'),
                            _buildStep(3, 'Enter UTR/Transaction ID'),
                            _buildStep(4, 'Wait for admin approval (1-2 hrs)'),
                          ],
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlanCard({
    required SubscriptionTier tier,
    required List<String> features,
    required List<String> lockedFeatures,
    required bool isCurrentPlan,
    bool isRecommended = false,
    int delay = 0,
  }) {
    final canUpgrade = !isCurrentPlan && SubscriptionService.currentTier.level < tier.level;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCurrentPlan
                  ? [tier.color.withOpacity(0.25), tier.color.withOpacity(0.1)]
                  : [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCurrentPlan ? tier.color : Colors.white.withOpacity(0.1),
              width: isCurrentPlan ? 2 : 1,
            ),
            boxShadow: isCurrentPlan
                ? [BoxShadow(color: tier.color.withOpacity(0.2), blurRadius: 20)]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          tier.color.withOpacity(0.3),
                          tier.color.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(tier.icon, color: tier.color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier.displayName,
                          style: GoogleFonts.poppins(
                            color: tier.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          tier.price,
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrentPlan)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: tier.color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Features
              ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.green, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
              
              // Locked features
              ...lockedFeatures.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.red, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
              
              // Upgrade button
              if (canUpgrade && !_hasPendingRequest) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      final result = await PaymentDialog.show(context, tier);
                      if (result == true) {
                        _checkPendingRequest();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tier.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rocket_launch, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Upgrade to ${tier.displayName}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Recommended badge
        if (isRecommended)
          Positioned(
            top: -10,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'BEST VALUE',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: 300 + delay)).slideX(begin: -0.1);
  }
}
