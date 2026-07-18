---
name: Emerald Trust
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#3c4a42'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#6c7a71'
  outline-variant: '#bbcabf'
  surface-tint: '#006c49'
  primary: '#006c49'
  on-primary: '#ffffff'
  primary-container: '#10b981'
  on-primary-container: '#00422b'
  inverse-primary: '#4edea3'
  secondary: '#4648d4'
  on-secondary: '#ffffff'
  secondary-container: '#6063ee'
  on-secondary-container: '#fffbff'
  tertiary: '#515f74'
  on-tertiary: '#ffffff'
  tertiary-container: '#95a4bb'
  on-tertiary-container: '#2c3a4d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#6ffbbe'
  primary-fixed-dim: '#4edea3'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#005236'
  secondary-fixed: '#e1e0ff'
  secondary-fixed-dim: '#c0c1ff'
  on-secondary-fixed: '#07006c'
  on-secondary-fixed-variant: '#2f2ebe'
  tertiary-fixed: '#d5e3fc'
  tertiary-fixed-dim: '#b9c7df'
  on-tertiary-fixed: '#0d1c2e'
  on-tertiary-fixed-variant: '#3a485b'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  numeric-data:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px
  grid_columns_desktop: '12'
  grid_gutter: 24px
  container_max_width: 1200px
---

## Brand & Style

The design system is engineered for **RentFlow**, a platform that balances the high-stakes nature of financial management with the communal dynamics of shared living. The brand personality is **efficient, transparent, and collaborative**, aiming to remove the friction and awkwardness often associated with rent collection.

The aesthetic follows a **Corporate / Modern** style with a focus on high-utility information density. It prioritizes clarity and trust through a "financial-first" lens—similar to modern fintech interfaces—utilizing generous whitespace, crisp structural lines, and a deliberate use of color to communicate status. The interface should feel robust enough to handle complex ledgers but approachable enough for casual daily use among roommates.

## Colors

This design system utilizes a palette rooted in financial psychology. The **Primary Emerald Green** is the core brand driver, used to reinforce "positive flow" and successful payment states. The **Secondary Indigo** is reserved for administrative tasks, structural navigation, and "Pending" states to distinguish them from completed actions.

- **Primary (Emerald):** Action buttons, success states, and progress completion.
- **Secondary (Indigo):** Links, toggle states, and informational callouts.
- **Slate/Neutral:** Used for backgrounds, borders, and secondary text to provide a stable, grounded foundation.
- **Semantic Palette:** Specific hues are assigned to financial statuses:
    - `Success`: Paid in full.
    - `Warning`: Overdue or nearing deadline.
    - `Error`: Payment rejected or failed.
    - `Pending`: Awaiting verification.
    - `Partial`: Split payments or installments.

## Typography

The design system uses **Inter** exclusively to ensure maximum legibility for numerical data and names. The system employs a "Tabular Numeral" feature (`tnum`) for all financial displays to ensure that currency amounts align perfectly in lists and tables.

- **Headlines:** Use Semi-Bold (600) weights with slightly tight letter spacing for a modern, authoritative feel.
- **Body:** Standardized at 16px for optimal reading on mobile devices.
- **Labels:** Small labels use a higher weight (600) and uppercase styling for "Status Badges" and "Overhead Titles" to create clear visual hierarchy.
- **Mobile Scaling:** Headlines scale down on mobile to prevent awkward line breaks in currency displays.

## Layout & Spacing

The design system relies on a **12-column fluid grid** for desktop and a **single-column vertical stack** for mobile. A strict 8px (base 4px) spacing rhythm is maintained to ensure a mathematical, "ledger-like" precision.

- **Content Containment:** Use a fixed-width container (1200px) on desktop to prevent data lines from becoming too long to read.
- **Data Density:** Use `md` (16px) padding for standard cards and `sm` (8px) for condensed list items to allow for high information density without feeling cluttered.
- **Mobile Strategy:** Increase side margins to `lg` (24px) on mobile to provide a comfortable "thumb-zone" and prevent accidental interactions.

## Elevation & Depth

This design system uses **Tonal Layers** and **Low-Contrast Outlines** rather than heavy shadows to maintain a clean, professional "SaaS" feel. Depth is used to separate the background from the interactive surface.

- **Level 0 (Background):** Solid `#F8FAFC` (Neutral).
- **Level 1 (Cards/Surface):** Pure White `#FFFFFF` with a 1px border in `#E2E8F0`.
- **Level 2 (Interactive/Floating):** Use a very soft, diffused shadow (0px 4px 12px rgba(0,0,0,0.05)) for elements like dropdowns or active modals to suggest they are "above" the ledger.
- **Separation:** Use thin horizontal dividers (`#F1F5F9`) between list items rather than distinct boxes to keep the "flow" of data uninterrupted.

## Shapes

The shape language is **Rounded**, using an 8px base radius to soften the "hard numbers" of financial management.

- **Cards & Inputs:** 8px (`rounded-md`) provides a professional, modern container.
- **Status Badges & Chips:** Utilize the `rounded-xl` (24px+) setting to create a "pill" shape, making them instantly distinguishable from square buttons or input fields.
- **Progress Bars:** Use fully rounded ends to feel approachable and less clinical.

## Components

### Buttons
- **Primary:** Solid Emerald Green with white text. High emphasis.
- **Secondary:** Outlined Slate or light Indigo wash. Used for "Add Expense" or "Edit."
- **Tertiary/Ghost:** No border, Indigo text. Used for "Cancel" or "View History."

### Cards
- Standard containers for "Property Overview" or "Roommate Balance." 
- Features a 1px border and a subtle Level 1 elevation on hover. 
- Padding is fixed at 24px (`lg`) to allow data to breathe.

### Status Chips
- Small, pill-shaped indicators.
- **Paid:** Light green background with dark green text.
- **Pending:** Light indigo background with dark indigo text.
- **Rejected:** Light red background with dark red text.

### Progress Bars
- 8px height. 
- Background is a neutral light gray; fill color matches the primary Emerald Green.
- Multi-segment bars can be used for "Partial" payments, showing segments in different colors (e.g., Green for paid, Indigo for pending).

### Input Fields
- White background with a 1px Slate border.
- Focus state: 2px Emerald Green border with a soft glow.
- Leading icons (e.g., "$" or "📅") should be used to provide context for financial data entry.

### List Items
- Used for transaction history.
- Features a left-aligned avatar or category icon, a center-aligned title/date, and a right-aligned bold currency amount using `numeric-data` typography.