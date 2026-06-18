content = open('lib/features/checkout/presentation/pages/checkout_page.dart', 'r', encoding='utf-8').read()
content = content.replace(
    '''                PaymentQrCard(formattedTotal: _formatPrice(checkoutTotalPrice)),
                const SizedBox(height: 28),

                // Summary Section''',
    '''                PaymentQrCard(formattedTotal: _formatPrice(checkoutTotalPrice)),
                const SizedBox(height: 28),

                // Coupon Section
                _buildSectionHeader('MAGIAMGIA (COUPON)', Icons.local_offer_outlined),
                const SizedBox(height: 12),
                _buildCouponSelector(checkoutTotalPrice),
                const SizedBox(height: 28),

                // Summary Section'''
)
open('lib/features/checkout/presentation/pages/checkout_page.dart', 'w', encoding='utf-8').write(content)
