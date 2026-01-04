class TimetableData {
  
  // 🔑 Helper to get schedule safely
  static Map<String, List<String>> getSchedule(String branch, String section) {
    // 1. Normalize Keys (Remove spaces, uppercase)
    // Example: Branch "CSE (AI&ML)" becomes "CSE-AIML"
    String normalizedBranch = branch.trim().toUpperCase()
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(' ', '-')
        .replaceAll('&', '');
    
    String key = "${normalizedBranch}_${section.trim().toUpperCase()}";
    
    // 2. Return Data
    return allSchedules[key] ?? _emptySchedule;
  }

  // 🕐 Period Timings (Official from RGMCET)
  static const Map<String, String> periodTimings = {
    'Period 1': '9:00 AM - 10:40 AM',
    'Break': '10:40 AM - 11:00 AM',
    'Period 2': '11:00 AM - 11:50 AM',
    'Period 3': '1:00 PM - 1:50 PM',
    'Lunch': '11:50 AM - 1:00 PM',
    'Period 4': '1:50 PM - 2:40 PM',
    'Period 5': '3:00 PM - 5:00 PM (Self-Study/Lab)',
  };

  // 📚 Subject Full Names
  static const Map<String, String> subjectNames = {
    // CSE Subjects
    'IP': 'Introduction to Programming',
    'CE': 'Communicative English',
    'CHE': 'Chemistry',
    'BCE': 'Basic Civil Engineering',
    'BME': 'Basic Mechanical Engineering',
    'LAAC': 'Linear Algebra & Advanced Calculus',
    'EAA': 'Health and Wellness, Yoga and Sports',
    'EWS': 'Engineering Work Shop',
    'S.S': 'Soft Skills',
    'IP LAB': 'Computer Programming Lab',
    'CE LAB': 'Communicative English Lab',
    'EC LAB': 'Engineering Chemistry Lab',
    
    // ECE/EEE/ME Subjects
    'EP': 'Engineering Physics',
    'BEE-A': 'Basic Electrical & Electronics Engineering - A',
    'BEE-B': 'Basic Electrical & Electronics Engineering - B',
    'EG': 'Engineering Graphics',
    'ITWS': 'IT Workshop',
    'EEEW LAB': 'Electrical & Electronics Engineering Workshop',
    'EP LAB': 'Engineering Physics Lab',
  };

  static final Map<String, List<String>> _emptySchedule = {
    'Monday': ['No Data', 'Contact Admin'],
    'Tuesday': ['No Data', 'Contact Admin'],
    'Wednesday': ['No Data', 'Contact Admin'],
    'Thursday': ['No Data', 'Contact Admin'],
    'Friday': ['No Data', 'Contact Admin'],
    'Saturday': ['No Data', 'Contact Admin'],
  };

  // 🗓️ THE MASTER DATABASE (2025-26) - VERIFIED FROM OFFICIAL TIMETABLES
  static final Map<String, Map<String, List<String>>> allSchedules = {

    // ================= ECE SECTIONS =================
    'ECE_A': {
      'Monday': ['EP', 'IP', 'LAAC', 'EG', 'EG'],
      'Tuesday': ['ITWS', 'ITWS', 'IP', 'S.S', 'S.S'],
      'Wednesday': ['EP LAB', 'EP LAB', 'BEE-A', 'EEEW LAB', 'EEEW LAB'],
      'Thursday': ['EP', 'LAAC', 'BEE-A', 'EG', 'EG'],
      'Friday': ['LAAC', 'BEE-B', 'IP LAB', 'IP LAB', 'EAA'],
      'Saturday': ['EEEW LAB', 'EEEW LAB', 'LAAC', 'BEE-B', 'IP LAB'],
    },
    'ECE_B': {
      'Monday': ['EP LAB', 'EP LAB', 'BEE-A', 'EAA', 'EAA'],
      'Tuesday': ['IP', 'BEE-A', 'EP', 'EG', 'EG'],
      'Wednesday': ['EEEW LAB', 'EEEW LAB', 'BEE-B', 'S.S', 'LAAC'],
      'Thursday': ['ITWS', 'ITWS', 'LAAC', 'EP', 'EP'],
      'Friday': ['EG', 'EG', 'BEE-B', 'IP LAB', 'IP LAB'],
      'Saturday': ['EP', 'LAAC', 'IP', 'IP LAB', 'EEEW LAB'],
    },
    'ECE_C': {
      'Monday': ['BEE-A', 'IP', 'EP', 'EG', 'EG'],
      'Tuesday': ['EEEW LAB', 'EEEW LAB', 'BEE-B', 'LAAC', 'IP LAB'],
      'Wednesday': ['ITWS', 'ITWS', 'LAAC', 'BEE-B', 'BEE-B'],
      'Thursday': ['EEEW LAB', 'EEEW LAB', 'LAAC', 'S.S', 'EP'],
      'Friday': ['EG', 'EG', 'IP LAB', 'IP LAB', 'EAA'],
      'Saturday': ['IP', 'BEE-A', 'EP', 'EP LAB', 'EP LAB'],
    },
    'ECE_D': {
      'Monday': ['EG', 'EG', 'EP', 'IP', 'EEEW LAB'],
      'Tuesday': ['EP LAB', 'EP LAB', 'LAAC', 'BEE-B', 'BEE-B'],
      'Wednesday': ['IP', 'EP', 'IP LAB', 'IP LAB', 'BEE-A'],
      'Thursday': ['EP', 'BEE-A', 'IP LAB', 'IP LAB', 'S.S'],
      'Friday': ['ITWS', 'ITWS', 'LAAC', 'EEEW LAB', 'EEEW LAB'],
      'Saturday': ['EG', 'EG', 'LAAC', 'BEE-B', 'EAA'],
    },

    // ================= EEE SECTIONS =================
    'EEE_A': {
      'Monday': ['IP', 'BEE-B', 'S.S', 'EAA', 'EAA'],
      'Tuesday': ['EG', 'EG', 'LAAC', 'IP LAB', 'IP LAB'],
      'Wednesday': ['EP', 'LAAC', 'BEE-A', 'ITWS', 'ITWS'],
      'Thursday': ['EEEW LAB', 'EEEW LAB', 'LAAC', 'IP', 'EG'],
      'Friday': ['BEE-A', 'LAAC', 'IP LAB', 'IP LAB', 'EP'],
      'Saturday': ['EP LAB', 'EP LAB', 'BEE-B', 'EEEW LAB', 'EEEW LAB'],
    },
    'EEE_B': {
      'Monday': ['EG', 'EG', 'IP LAB', 'IP LAB', 'EEEW LAB'],
      'Tuesday': ['BEE-B', 'BEE-A', 'IP', 'EP LAB', 'EP LAB'],
      'Wednesday': ['IP LAB', 'IP LAB', 'BEE-B', 'LAAC', 'S.S'],
      'Thursday': ['EG', 'EG', 'EP', 'EEEW LAB', 'EEEW LAB'],
      'Friday': ['LAAC', 'IP', 'EP', 'EAA', 'EAA'],
      'Saturday': ['BEE-A', 'LAAC', 'IP', 'ITWS', 'ITWS'],
    },

    // ================= EEE SECTIONS (CONTINUED) =================
    'EEE_C': {
      'Monday': ['LAAC', 'EP', 'BEE-A', 'ITWS', 'ITWS'],
      'Tuesday': ['IP LAB', 'IP LAB', 'EP', 'EG', 'EG'],
      'Wednesday': ['BEE-B', 'IP', 'EEEW LAB', 'EEEW LAB', 'S.S'],
      'Thursday': ['EP LAB', 'EP LAB', 'BEE-A', 'LAAC', 'EAA'],
      'Friday': ['EG', 'EG', 'LAAC', 'IP LAB', 'IP LAB'],
      'Saturday': ['IP', 'BEE-B', 'EP', 'EEEW LAB', 'EEEW LAB'],
    },
    'EEE_D': {
      'Monday': ['ITWS', 'ITWS', 'EP', 'IP LAB', 'IP LAB'],
      'Tuesday': ['LAAC', 'BEE-A', 'EG', 'EG', 'S.S'],
      'Wednesday': ['EP LAB', 'EP LAB', 'IP', 'BEE-B', 'EAA'],
      'Thursday': ['BEE-A', 'LAAC', 'EEEW LAB', 'EEEW LAB', 'EP'],
      'Friday': ['IP', 'BEE-B', 'EG', 'EG', 'LAAC'],
      'Saturday': ['EEEW LAB', 'EEEW LAB', 'IP LAB', 'IP LAB', 'EP'],
    },

    // ================= ME SECTIONS =================
    'ME_A': {
      'Monday': ['LAAC', 'BEE-A', 'BEE-B', 'EP LAB', 'EP LAB'],
      'Tuesday': ['BEE-A', 'IP', 'EP', 'ITWS', 'ITWS'],
      'Wednesday': ['EEEW LAB', 'EEEW LAB', 'IP', 'EP', 'EG'],
      'Thursday': ['IP LAB', 'IP LAB', 'BEE-B', 'S.S', 'EP'],
      'Friday': ['IP LAB', 'IP LAB', 'LAAC', 'EEEW LAB', 'EEEW LAB'],
      'Saturday': ['LAAC', 'BEE-B', 'IP', 'EG', 'EG'],
    },
    'ME_B': {
      'Monday': ['IP', 'EP', 'LAAC', 'EG', 'EG'],
      'Tuesday': ['EEEW LAB', 'EEEW LAB', 'BEE-A', 'IP LAB', 'IP LAB'],
      'Wednesday': ['BEE-B', 'LAAC', 'EP LAB', 'EP LAB', 'S.S'],
      'Thursday': ['EG', 'EG', 'IP', 'ITWS', 'ITWS'],
      'Friday': ['BEE-A', 'BEE-B', 'EEEW LAB', 'EEEW LAB', 'EAA'],
      'Saturday': ['EP', 'LAAC', 'IP LAB', 'IP LAB', 'EP'],
    },

    // ================= CSE-AIML SECTIONS =================
    'CSE-AIML_A': {
      'Monday': ['EEEW LAB', 'EEEW LAB', 'IP', 'EP', 'S.S'],
      'Tuesday': ['IP', 'BEE-A', 'IP LAB', 'IP LAB', 'LAAC'],
      'Wednesday': ['EG', 'EG', 'LAAC', 'BEE-A', 'BEE-A'],
      'Thursday': ['EP', 'LAAC', 'EEEW LAB', 'EEEW LAB', 'EAA'],
      'Friday': ['EP LAB', 'EP LAB', 'IP LAB', 'IP LAB', 'BEE-B'],
      'Saturday': ['ITWS', 'ITWS', 'BEE-B', 'EG', 'EG'],
    },
    'CSE-AIML_B': {
      'Monday': ['IP', 'BEE-B', 'EP', 'ITWS', 'ITWS'],
      'Tuesday': ['EG', 'EG', 'EEEW LAB', 'EEEW LAB', 'EAA'],
      'Wednesday': ['S.S', 'BEE-A', 'BEE-B', 'IP LAB', 'IP LAB'],
      'Thursday': ['EP LAB', 'EP LAB', 'LAAC', 'IP', 'EP'],
      'Friday': ['EG', 'EG', 'EEEW LAB', 'EEEW LAB', 'LAAC'],
      'Saturday': ['LAAC', 'EP', 'IP LAB', 'IP LAB', 'BEE-A'],
    },
    'CSE-AIML_C': {
      'Monday': ['ITWS', 'ITWS', 'LAAC', 'BEE-A', 'BEE-A'],
      'Tuesday': ['S.S', 'LAAC', 'IP', 'EEEW LAB', 'EEEW LAB'],
      'Wednesday': ['EG', 'EG', 'IP LAB', 'IP LAB', 'EP'],
      'Thursday': ['BEE-B', 'IP', 'EP', 'EP LAB', 'EP LAB'],
      'Friday': ['EEEW LAB', 'EEEW LAB', 'EP', 'BEE-B', 'EG'],
      'Saturday': ['IP LAB', 'IP LAB', 'BEE-A', 'LAAC', 'EAA'],
    },
    'CSE-AIML_D': {
      'Monday': ['BEE-B', 'EP', 'IP LAB', 'IP LAB', 'EAA'],
      'Tuesday': ['EP', 'LAAC', 'BEE-A', 'EG', 'EG'],
      'Wednesday': ['LAAC', 'IP', 'EEEW LAB', 'EEEW LAB', 'S.S'],
      'Thursday': ['EG', 'EG', 'IP', 'ITWS', 'ITWS'],
      'Friday': ['LAAC', 'IP', 'EP', 'EP LAB', 'EP LAB'],
      'Saturday': ['BEE-A', 'BEE-B', 'EEEW LAB', 'EEEW LAB', 'IP LAB'],
    },

    // ================= CSE (CORE) SECTIONS =================
    'CSE_A': {
      'Monday': ['BME', 'BCE', 'CHE', 'LAAC', 'LAAC'],
      'Tuesday': ['S.S', 'IP', 'IP LAB', 'IP LAB', 'CE'],
      'Wednesday': ['CHE', 'CE', 'BCE', 'IP LAB', 'IP LAB'],
      'Thursday': ['CE LAB', 'CE LAB', 'IP', 'LAAC', 'LAAC'],
      'Friday': ['CE', 'IP', 'CHE', 'EWS', 'EWS'],
      'Saturday': ['EC LAB', 'EC LAB', 'LAAC', 'BME', 'EAA'],
    },
    'CSE_B': {
      'Monday': ['BCE', 'IP', 'LAAC', 'CE LAB', 'CE LAB'],
      'Tuesday': ['CHE', 'IP', 'CE', 'IP LAB', 'IP LAB'],
      'Wednesday': ['S.S', 'BCE', 'IP LAB', 'IP LAB', 'CE'],
      'Thursday': ['IP', 'CHE', 'LAAC', 'BME', 'BME'],
      'Friday': ['EWS', 'EWS', 'CHE', 'EAA', 'EAA'],
      'Saturday': ['LAAC', 'BME', 'CE', 'EC LAB', 'EC LAB'],
    },
    'CSE_C': {
      'Monday': ['CE LAB', 'CE LAB', 'S.S', 'LAAC', 'LAAC'],
      'Tuesday': ['CE', 'BME', 'IP LAB', 'IP LAB', 'BME'],
      'Wednesday': ['IP', 'LAAC', 'CHE', 'EWS', 'EWS'],
      'Thursday': ['LAAC', 'CE', 'CHE', 'IP LAB', 'IP LAB'],
      'Friday': ['EC LAB', 'EC LAB', 'IP', 'BCE', 'BCE'],
      'Saturday': ['CE', 'BCE', 'CHE', 'EAA', 'EAA'],
    },
    'CSE_D': {
      'Monday': ['BCE', 'CHE', 'CE', 'S.S', 'S.S'],
      'Tuesday': ['LAAC', 'IP', 'BME', 'EC LAB', 'EC LAB'],
      'Wednesday': ['EWS', 'EWS', 'CE', 'EAA', 'EAA'],
      'Thursday': ['LAAC', 'IP', 'IP LAB', 'IP LAB', 'CHE'],
      'Friday': ['CHE', 'CE', 'BME', 'IP LAB', 'IP LAB'],
      'Saturday': ['IP', 'LAAC', 'BCE', 'CE LAB', 'CE LAB'],
    },
    'CSE_E': {
      'Monday': ['LAAC', 'CE', 'CHE', 'EC LAB', 'EC LAB'],
      'Tuesday': ['IP', 'BCE', 'CE', 'CE LAB', 'CE LAB'],
      'Wednesday': ['CHE', 'CE', 'S.S', 'IP LAB', 'IP LAB'],
      'Thursday': ['EWS', 'EWS', 'BCE', 'EAA', 'EAA'],
      'Friday': ['BME', 'LAAC', 'IP LAB', 'IP LAB', 'CHE'],
      'Saturday': ['CE', 'BME', 'IP', 'LAAC', 'LAAC'],
    },
    'CSE_F': {
      'Monday': ['IP', 'LAAC', 'CE', 'CHE', 'CHE'],
      'Tuesday': ['LAAC', 'BME', 'BCE', 'EWS', 'EWS'],
      'Wednesday': ['BME', 'IP', 'IP LAB', 'IP LAB', 'CE'],
      'Thursday': ['S.S', 'CE', 'CHE', 'EC LAB', 'EC LAB'],
      'Friday': ['CHE', 'IP', 'BCE', 'IP LAB', 'IP LAB'],
      'Saturday': ['CE LAB', 'CE LAB', 'LAAC', 'EAA', 'EAA'],
    },

    // ================= CSE-DS SECTIONS =================
    'CSE-DS_A': {
      'Monday': ['CE', 'IP', 'BME', 'IP LAB', 'IP LAB'],
      'Tuesday': ['LAAC', 'IP', 'S.S', 'CE', 'CE'],
      'Wednesday': ['CE LAB', 'CE LAB', 'CHE', 'BCE', 'BCE'],
      'Thursday': ['IP LAB', 'IP LAB', 'LAAC', 'LAAC', 'EAA'],
      'Friday': ['IP', 'LAAC', 'CHE', 'EC LAB', 'EC LAB'],
      'Saturday': ['CHE', 'BCE', 'BME', 'EWS', 'EWS'],
    },
    'CSE-DS_B': {
      'Monday': ['S.S', 'CHE', 'CE', 'EWS', 'EWS'],
      'Tuesday': ['BCE', 'CHE', 'LAAC', 'IP LAB', 'IP LAB'],
      'Wednesday': ['IP', 'LAAC', 'BME', 'CE LAB', 'CE LAB'],
      'Thursday': ['EC LAB', 'EC LAB', 'CE', 'EAA', 'EAA'],
      'Friday': ['IP LAB', 'IP LAB', 'CHE', 'LAAC', 'BME'],
      'Saturday': ['IP', 'BCE', 'CE', 'CHE', 'CHE'],
    },
    'CSE-DS_C': {
      'Monday': ['S.S', 'LAAC', 'CHE', 'BME', 'BME'],
      'Tuesday': ['CE LAB', 'CE LAB', 'LAAC', 'EAA', 'EAA'],
      'Wednesday': ['IP LAB', 'IP LAB', 'LAAC', 'CE', 'EC LAB'],
      'Thursday': ['CE', 'BCE', 'BME', 'EWS', 'EWS'],
      'Friday': ['CHE', 'CE', 'IP', 'IP LAB', 'IP LAB'],
      'Saturday': ['LAAC', 'CHE', 'IP', 'BCE', 'BCE'],
    },

    // ================= CSE-CS SECTIONS =================
    'CSE-CS_A': {
      'Monday': ['BCE', 'CE', 'LAAC', 'CHE', 'CHE'],
      'Tuesday': ['EWS', 'EWS', 'IP LAB', 'IP LAB', 'S.S'],
      'Wednesday': ['EC LAB', 'EC LAB', 'BME', 'IP LAB', 'IP LAB'],
      'Thursday': ['IP', 'LAAC', 'CHE', 'CE LAB', 'CE LAB'],
      'Friday': ['CE', 'BME', 'LAAC', 'EAA', 'EAA'],
      'Saturday': ['CHE', 'BCE', 'IP', 'CE', 'CE'],
    },
    'CSE-CS_B': {
      'Monday': ['EWS', 'EWS', 'BME', 'EAA', 'EAA'],
      'Tuesday': ['EC LAB', 'EC LAB', 'LAAC', 'IP LAB', 'IP LAB'],
      'Wednesday': ['BCE', 'BME', 'IP LAB', 'IP LAB', 'CE'],
      'Thursday': ['S.S', 'CHE', 'IP', 'LAAC', 'LAAC'],
      'Friday': ['CHE', 'CE', 'BCE', 'CE LAB', 'CE LAB'],
      'Saturday': ['IP', 'LAAC', 'CHE', 'CE', 'CE'],
    },
  };
}
