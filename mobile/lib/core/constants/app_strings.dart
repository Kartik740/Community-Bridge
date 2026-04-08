// lib/core/constants/app_strings.dart
// All user-visible strings in a single file to prevent hardcoding.

class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'CommunityBridge';
  static const String tagline = 'Connecting volunteers with communities in need';

  // Auth — Login
  static const String login = 'Login';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String loginSubtitle = 'Welcome back, volunteer';
  static const String noAccount = 'New volunteer? Apply to an NGO';
  static const String loginError = 'Invalid credentials. Please try again.';
  static const String loginFailed = 'Login failed. Check your connection.';

  // Auth — Register
  static const String register = 'Register';
  static const String applyToNGO = 'Apply to an NGO';
  static const String step1Title = 'Account Details';
  static const String step2Title = 'Volunteer Details';
  static const String step3Title = 'Choose NGO';
  static const String fullName = 'Full Name';
  static const String age = 'Age';
  static const String city = 'City';
  static const String phone = 'Phone Number';
  static const String confirmPassword = 'Confirm Password';
  static const String skills = 'Your Skills';
  static const String availability = 'Availability';
  static const String motivation = 'Why do you want to volunteer? (optional)';
  static const String selectNGO = 'Select the NGO you want to volunteer with';
  static const String submitApplication = 'Submit Application';
  static const String next = 'Next';
  static const String back = 'Back';

  // Availability options
  static const Map<String, String> availabilityOptions = {
    'mornings': 'Mornings (6am – 12pm)',
    'evenings': 'Evenings (4pm – 9pm)',
    'weekends': 'Weekends Only',
    'fulltime': 'Full Time Available',
  };

  // Skill options
  static const List<String> skillOptions = [
    'medical',
    'education',
    'logistics',
    'construction',
    'counselling',
  ];

  // Pending
  static const String pendingTitle = 'Application Submitted!';
  static const String pendingSubtitle =
      'Your application is under review. You will be notified once the organiser approves your request.';
  static const String logout = 'Logout';
  static const String logoutConfirm = 'Are you sure you want to logout?';

  // Rejected
  static const String rejectedTitle = 'Application Not Approved';
  static const String applyDifferentNGO = 'Apply to a Different NGO';

  // Home
  static const String findSurvey = 'Find a Survey';
  static const String surveyCodeHint = 'Enter Survey Code';
  static const String search = 'Search';
  static const String recentlySeen = 'Recently Used';
  static const String offlineMessage =
      'You are offline — forms saved locally';
  static const String pendingSyncMessage = 'responses pending sync';
  static const String syncNow = 'Sync Now';

  // Survey
  static const String surveyNotFound =
      'Survey not found. Check the code and try again.';
  static const String surveyOfflineNotCached =
      'You are offline. This survey is not cached on your device.';
  static const String capturingLocation = 'Capturing location...';
  static const String locationCaptured = 'Location captured';
  static const String submitSurvey = 'Submit Survey';
  static const String offlineMode = 'Offline';
  static const String onlineMode = 'Online';

  // Success
  static const String syncedTitle = 'Response Submitted!';
  static const String savedOfflineTitle = 'Response Saved Locally';
  static const String fillAnother = 'Fill Another Survey';
  static const String goHome = 'Go to Home';

  // Tasks
  static const String myTasks = 'My Tasks';
  static const String noTasks = 'No tasks assigned yet';
  static const String noTasksSubtitle =
      'The NGO will assign tasks based on community needs and your skills.';
  static const String whatToDo = 'What To Do';
  static const String getDirections = 'Get Directions';
  static const String onMyWay = 'On My Way';
  static const String markComplete = 'Mark as Completed';
  static const String taskCompleted = 'Task Completed';
  static const String confirmComplete =
      'Are you sure you want to mark this task complete?';
  static const String confirm = 'Confirm';
  static const String cancel = 'Cancel';

  // Profile
  static const String profile = 'Profile';
  static const String availableForTasks = 'Available for tasks';
  static const String notAvailable = 'Not available';
  static const String updateLocation = 'Update Location';
  static const String locationUpdated = 'Location updated successfully!';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String noInternet = 'No internet connection';
}
