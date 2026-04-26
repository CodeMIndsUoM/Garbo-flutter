/// Constants used by the citizen request page and its sub-widgets.
library;

const List<(String, String)> statusFilterOptions = [
  ('ALL', 'All'),
  ('OPEN', 'Open'),
  ('ASSIGNED', 'Assigned'),
  ('COMPLETED', 'Completed'),
  ('CONFIRMED', 'Confirmed'),
  ('CANCELLED', 'Cancelled'),
];

const List<String> wasteTypeItems = [
  'Plastic',
  'Glass',
  'Metal',
  'E-Waste',
  'Paper',
  'Organic',
  'Textile',
  'Mixed',
];

const List<String> quantityItems = [
  'Small (1-2 bags/items)',
  'Medium (3-5 bags/items)',
  'Large (6-10 bags/items)',
  'Extra Large (10+ bags/items)',
];

const List<String> timeSlotItems = [
  'Morning (8AM-12PM)',
  'Afternoon (12PM-4PM)',
  'Evening (4PM-7PM)',
];
