class AppConstants {
  // App Info
  static const String appName = 'Temple App';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String templesCollection = 'temples';
  static const String poojasCollection = 'poojas';
  static const String eventsCollection = 'events';
  static const String donationsCollection = 'donations';
  static const String darshansCollection = 'darshans';
  static const String announcementsCollection = 'announcements';
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String rolePurohit = 'purohit';
  static const String roleUser = 'user';
  
  // Pooja Types
  static const List<String> poojaTypes = [
    'Morning Pooja',
    'Evening Pooja',
    'Abhishekam',
    'Archana',
    'Special Pooja',
    'Weekly Pooja',
    'Monthly Pooja',
    'Annual Pooja',
  ];
  
  // Days of Week
  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
    'All Days',
  ];
  
  // Donation Categories
  static const List<String> donationCategories = [
    'General Donation',
    'Temple Development',
    'Annadanam (Food Donation)',
    'Flower Offerings',
    'Oil for Lamps',
    'Festival Celebration',
    'Temple Maintenance',
    'Charity',
  ];
  
  // Darshan Slots
  static const List<String> darshanSlots = [
    '5:00 AM - 6:00 AM',
    '6:00 AM - 7:00 AM',
    '7:00 AM - 12:00 PM',
    '12:00 PM - 1:00 PM',
    '1:00 PM - 5:00 PM',
    '5:00 PM - 6:00 PM',
    '6:00 PM - 7:00 PM',
    '7:00 PM - 8:00 PM',
    '8:00 PM - 9:00 PM',
  ];
}
