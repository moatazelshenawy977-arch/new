// Image slots. Unsplash photos (Unsplash License: free for commercial use, no permission needed).
// Swap `image` for your own assets at any time; `art` is the generated fallback if a link fails.
const U = (id) => `https://images.unsplash.com/photo-${id}?fm=jpg&q=80&w=900&h=1260&fit=crop&auto=format`;

export const CARDS = [
  { title: 'AI Sales Assistant',  tag: 'Sales / Chat',        text: 'Answers new leads in seconds, asks the right questions and books the viewing.',          image: U('1791960296842-2c748982383e'), art: ['#0f7f69', '#b8ecd8'] },
  { title: 'Property Match',      tag: 'Real estate / AI',    text: 'Matches each buyer to the listings that fit budget, area and lifestyle.',                image: U('1791960297289-903de2570d63'), art: ['#6a4cff', '#f1c4dc'] },
  { title: 'WhatsApp Lead Bot',   tag: 'Automation',          text: 'Captures leads from ads and replies on WhatsApp, in Arabic and English.',                image: U('1791960467057-9de83e2f1286'), art: ['#3687ff', '#d3c2f5'] },
  { title: 'Follow-up Engine',    tag: 'CRM / Automation',    text: 'No lead goes cold: reminders and messages are sent at the right time.',                  image: U('1791960297015-3120d553e763'), art: ['#ff4f36', '#f1c4dc'] },
  { title: 'Listing Studio',      tag: 'Content / AI',        text: 'Turns raw property details into polished listings, captions and ads.',                   image: U('1791960297273-6c4a76657fde'), art: ['#101214', '#6a4cff'] },
  { title: 'Shipment Tracker',    tag: 'Logistics',           text: 'Live status updates sent to customers, with no manual calls.',                           image: U('1791960466942-a056e967961a'), art: ['#f4ff1e', '#0f7f69'] },
  { title: 'Deal Dashboard',      tag: 'Reporting',           text: 'One screen with leads, visits, offers and revenue by agent and campaign.',               image: U('1792121796712-4f8dcf54de70'), art: ['#9fb0f5', '#f1c4dc'] },
  { title: 'Support Agent',       tag: 'Customer support',    text: 'Handles common questions around the clock and hands over to a human when needed.',       image: U('1784142269410-2b5ddb689a04'), art: ['#3687ff', '#b8ecd8'] },
];

export const CREDITS = 'Photos: Unsplash (Unsplash License). Fonts: Space Grotesk, JetBrains Mono, Manrope, Noto Sans JP (SIL OFL).';
