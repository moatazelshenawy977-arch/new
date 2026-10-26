// Image slots. Unsplash photos (Unsplash License: free for commercial use, no permission needed).
// Swap `image` for your own assets at any time; `art` is the generated fallback if a link fails.
const U = (id) => `https://images.unsplash.com/photo-${id}?fm=jpg&q=80&w=900&h=1260&fit=crop&auto=format`;

// SAMPLE LISTINGS: names and details are made-up placeholders. Prices are calibrated to public
// market averages (2026): Sheikh Zayed ~EGP 64-72K/m2, New Cairo ~EGP 61-97K/m2,
// North Coast ~EGP 76K/m2, Business Bay ~AED 2,550/sq ft. Replace with real inventory.
export const CARDS = [
  { country: 'eg', title: 'Palm Hills Villa',  tag: '6th of October, Egypt',   type: 'Villa',     price: 'EGP 28M',   beds: 5, baths: 5, size: '420 m²', text: 'Corner villa with private garden and pool, in a gated compound with 24/7 security.', image: U('1613977257363-707ba9348227'), art: ['#0f7f69', '#b8ecd8'],
    ar: { title: 'فيلا بالم هيلز', tag: '٦ أكتوبر، مصر', type: 'فيلا', text: 'فيلا ركن بحديقة خاصة وحمام سباحة داخل كمبوند مغلق بأمن على مدار الساعة.' } },
  { country: 'eg', title: 'Marina Sea View',   tag: 'North Coast, Egypt',      type: 'Chalet',    price: 'EGP 10.3M', beds: 2, baths: 2, size: '135 m²', text: 'Sea-view chalet, 3 minutes from the beach, fully finished and furnished.', image: U('1757524552833-4dba4949a5b2'), art: ['#3687ff', '#d3c2f5'],
    ar: { title: 'مارينا سي فيو', tag: 'الساحل الشمالي، مصر', type: 'شاليه', text: 'شاليه بإطلالة على البحر، على بعد ٣ دقائق من الشاطئ، متشطب بالكامل ومفروش.' } },
  { country: 'eg', title: 'New Cairo Duplex',  tag: 'Fifth Settlement, Cairo', type: 'Duplex',    price: 'EGP 16M',   beds: 4, baths: 3, size: '260 m²', text: 'Duplex with a rooftop terrace, near the American University and main roads.', image: U('1706808849780-7a04fbac83ef'), art: ['#6a4cff', '#f1c4dc'],
    ar: { title: 'دوبلكس القاهرة الجديدة', tag: 'التجمع الخامس، القاهرة', type: 'دوبلكس', text: 'دوبلكس بروف خاص بالقرب من الجامعة الأمريكية والطرق الرئيسية.' } },
  { country: 'ae', title: 'Downtown Tower 24', tag: 'Downtown Dubai, UAE',     type: 'Apartment', price: 'AED 2.4M',  beds: 1, baths: 2, size: '78 m²',  text: 'High-floor apartment with city views. Strong rental demand and flexible payment plan.', image: U('1784853879843-f3c5aacf2569'), art: ['#101214', '#6a4cff'],
    ar: { title: 'داون تاون تاور ٢٤', tag: 'داون تاون دبي، الإمارات', type: 'شقة', text: 'شقة في طابق مرتفع بإطلالة على المدينة، طلب إيجاري قوي وخطة سداد مرنة.' } },
  { country: 'eg', title: 'Garden Residence',  tag: 'New Capital, Egypt',      type: 'Apartment', price: 'EGP 5M',    beds: 3, baths: 2, size: '165 m²', text: 'Ground-floor apartment with its own garden. Delivery in 2027, 8-year installments.', image: U('1758448756362-e323282ccbcc'), art: ['#f4ff1e', '#0f7f69'],
    ar: { title: 'جاردن ريزيدنس', tag: 'العاصمة الإدارية، مصر', type: 'شقة', text: 'شقة أرضية بحديقة خاصة. التسليم ٢٠٢٧ وتقسيط على ٨ سنوات.' } },
  { country: 'sa', title: 'Riyadh Boulevard',  tag: 'Riyadh, Saudi Arabia',    type: 'Apartment', price: 'SAR 1.9M',  beds: 2, baths: 2, size: '112 m²', text: 'Modern apartment close to the boulevard, restaurants and metro.', image: U('1525953776754-6c4b7ee655ab'), art: ['#ff4f36', '#f1c4dc'],
    ar: { title: 'بوليفارد الرياض', tag: 'الرياض، السعودية', type: 'شقة', text: 'شقة حديثة قريبة من البوليفارد والمطاعم والمترو.' } },
  { country: 'eg', title: 'Lagoon Townhouse',  tag: 'Sheikh Zayed, Egypt',     type: 'Townhouse', price: 'EGP 21M',   beds: 4, baths: 4, size: '300 m²', text: 'Townhouse on a lagoon with a private garden and a community club.', image: U('1668911494509-14baf3b42fda'), art: ['#9fb0f5', '#f1c4dc'],
    ar: { title: 'تاون هاوس لاجون', tag: 'الشيخ زايد، مصر', type: 'تاون هاوس', text: 'تاون هاوس على لاجون مع حديقة خاصة ونادٍ للسكان.' } },
  { country: 'ae', title: 'Studio Investor',   tag: 'Business Bay, UAE',       type: 'Studio',    price: 'AED 1.05M', beds: 0, baths: 1, size: '38 m²',  text: 'Compact studio built for investors, with a guaranteed rental yield option.', image: U('1515263487990-61b07816b324'), art: ['#3687ff', '#b8ecd8'],
    ar: { title: 'استوديو للمستثمرين', tag: 'الخليج التجاري، الإمارات', type: 'استوديو', text: 'استوديو مدمج للمستثمرين مع خيار عائد إيجاري مضمون.' } },
];

export const CREDITS = 'Photos: Unsplash (Unsplash License). Fonts: Space Grotesk, JetBrains Mono, Manrope, Noto Sans JP/Arabic (SIL OFL).';
