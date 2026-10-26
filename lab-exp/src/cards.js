// Image slots. Unsplash photos (Unsplash License: free for commercial use, no permission needed).
// Swap `image` for your own assets at any time; `art` is the generated fallback if a link fails.
const U = (id) => `https://images.unsplash.com/photo-${id}?fm=jpg&q=80&w=900&h=1260&fit=crop&auto=format`;

// SAMPLE LISTINGS: all names, prices and details are made-up placeholders. Replace with real inventory.
export const CARDS = [
  { title: 'Palm Hills Villa',   tag: '6th of October, Egypt',  type: 'Villa',      price: 'EGP 18.5M', beds: 5, baths: 5, size: '420 m²', text: 'Corner villa with private garden and pool, in a gated compound with 24/7 security.',   image: U('1613977257363-707ba9348227'), art: ['#0f7f69', '#b8ecd8'] },
  { title: 'Marina Sea View',    tag: 'North Coast, Egypt',     type: 'Chalet',     price: 'EGP 7.2M',  beds: 2, baths: 2, size: '135 m²', text: 'Sea-view chalet, 3 minutes from the beach, fully finished and furnished.',             image: U('1757524552833-4dba4949a5b2'), art: ['#3687ff', '#d3c2f5'] },
  { title: 'New Cairo Duplex',   tag: 'Fifth Settlement, Cairo', type: 'Duplex',    price: 'EGP 9.8M',  beds: 4, baths: 3, size: '260 m²', text: 'Duplex with a rooftop terrace, near the American University and main roads.',          image: U('1706808849780-7a04fbac83ef'), art: ['#6a4cff', '#f1c4dc'] },
  { title: 'Downtown Tower 24',  tag: 'Downtown Dubai, UAE',    type: 'Apartment',  price: 'AED 2.4M',  beds: 1, baths: 2, size: '78 m²',  text: 'High-floor apartment with city views. Strong rental demand and flexible payment plan.', image: U('1784853879843-f3c5aacf2569'), art: ['#101214', '#6a4cff'] },
  { title: 'Garden Residence',   tag: 'New Capital, Egypt',     type: 'Apartment',  price: 'EGP 4.1M',  beds: 3, baths: 2, size: '165 m²', text: 'Ground-floor apartment with its own garden. Delivery in 2027, 8-year installments.',    image: U('1758448756362-e323282ccbcc'), art: ['#f4ff1e', '#0f7f69'] },
  { title: 'Riyadh Boulevard',   tag: 'Riyadh, Saudi Arabia',   type: 'Apartment',  price: 'SAR 1.9M',  beds: 2, baths: 2, size: '112 m²', text: 'Modern apartment close to the boulevard, restaurants and metro.',                        image: U('1525953776754-6c4b7ee655ab'), art: ['#ff4f36', '#f1c4dc'] },
  { title: 'Lagoon Townhouse',   tag: 'Sheikh Zayed, Egypt',    type: 'Townhouse',  price: 'EGP 12.3M', beds: 4, baths: 4, size: '300 m²', text: 'Townhouse on a lagoon with a private garden and a community club.',                      image: U('1668911494509-14baf3b42fda'), art: ['#9fb0f5', '#f1c4dc'] },
  { title: 'Studio Investor',    tag: 'Business Bay, UAE',      type: 'Studio',     price: 'AED 890K',  beds: 0, baths: 1, size: '38 m²',  text: 'Compact studio built for investors, with a guaranteed rental yield option.',             image: U('1515263487990-61b07816b324'), art: ['#3687ff', '#b8ecd8'] },
];

export const CREDITS = 'Photos: Unsplash (Unsplash License). Fonts: Space Grotesk, JetBrains Mono, Manrope, Noto Sans JP (SIL OFL).';
