import re

with open('lib/features/checkout/presentation/pages/checkout_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Resolve all conflicts: keep the a4cb154 side (after ======, before >>>>>)
pattern = r'<<<<<<< HEAD\n(.*?)=======\n(.*?)>>>>>>>'
while True:
    m = re.search(pattern, content, re.DOTALL)
    if not m:
        break
    content = content[:m.start()] + m.group(2) + content[m.end():]

with open('lib/features/checkout/presentation/pages/checkout_page.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('checkout_page.dart conflicts resolved')
# Check coupon
call = '_buildCouponSelector(checkoutTotalPrice)' in content
print(f'Coupon called in build: {call}')
