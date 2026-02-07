class TimetableData {
  
  // 🔑 Helper to get schedule safely
  static Map<String, List<String>> getSchedule(String branch, String section) {
    // 1. Normalize Keys (Remove spaces, uppercase)
    String normalizedBranch = branch.trim().toUpperCase()
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(' ', '-')
        .replaceAll('&', '');
    
    String key = "${normalizedBranch}_${section.trim().toUpperCase()}";
    
    // 2. Return Data
    return allSchedules[key] ?? _emptySchedule;
  }

  // 🕐 Period Timings (Official from RGMCET - WEF 05.02.2026)
  static const Map<String, String> periodTimings = {
    'Period 1': '9:00 AM - 10:40 AM',
    'Period 2': '11:00 AM - 11:50 AM',
    'Period 3': '1:00 PM - 1:50 PM',
    'Period 4': '1:50 PM - 2:40 PM',
    'Period 5': '3:00 PM - 5:00 PM',
  };

  // 📚 Subject Full Names (Updated Feb 2026)
  static const Map<String, String> subjectNames = {
    // Common Subjects
    'CHE': 'Chemistry',
    'CHE LAB': 'Chemistry Lab',
    'CE': 'Communicative English',
    'CE LAB': 'Communicative English Lab',
    'BCE': 'Basic Civil Engineering',
    'BME': 'Basic Mechanical Engineering',
    'EWS': 'Engineering Workshop',
    'EAA': 'Health & Wellness, Yoga and Sports',
    'SS': 'Soft Skills',
    
    // Programming & CS Subjects
    'DEVC': 'Development in C',
    'DS': 'Data Structures',
    'DS LAB': 'Data Structures Lab',
    'ITWS': 'IT Workshop',
    
    // Electronics & Electrical
    'NWA': 'Network Analysis',
    'NWA LAB': 'Network Analysis Lab',
    'ECA': 'Electronic Circuit Analysis',
    'ECA LAB': 'Electronic Circuit Analysis Lab',
    'NWA/ECA': 'Network Analysis / Electronic Circuit Analysis',
    'NWA/ECA LAB': 'Network Analysis / Electronic Circuit Analysis Lab',
    'BEE A': 'Basic Electrical Engineering - A',
    'BEE B': 'Basic Electrical Engineering - B',
    'EEEW LAB': 'Electrical & Electronics Engineering Workshop',
    
    // Physics & Graphics
    'EP': 'Engineering Physics',
    'EP LAB': 'Engineering Physics Lab',
    'EG': 'Engineering Graphics',
    
    // Mechanical
    'EM': 'Engineering Mechanics',
    'EM LAB': 'Engineering Mechanics Lab',
    
    // Free Period
    'Free': 'Free Period',
  };

  static final Map<String, List<String>> _emptySchedule = {
    'Monday': ['No Data', 'Contact Admin', 'Free', 'Free', 'Free'],
    'Tuesday': ['No Data', 'Contact Admin', 'Free', 'Free', 'Free'],
    'Wednesday': ['No Data', 'Contact Admin', 'Free', 'Free', 'Free'],
    'Thursday': ['No Data', 'Contact Admin', 'Free', 'Free', 'Free'],
    'Friday': ['No Data', 'Contact Admin', 'Free', 'Free', 'Free'],
    'Saturday': ['No Data', 'Contact Admin', 'Free', 'Free', 'Free'],
  };

  // 🗓️ THE MASTER DATABASE (Feb 2026 - R23 Regulation)
  // WEF: 05.02.2026 | 5 Periods Per Day
  // Format: [P1(9:00-10:40), P2(11:00-11:50), P3(1:00-1:50), P4(1:50-2:40), P5(3:00-5:00)]
  static final Map<String, Map<String, List<String>>> allSchedules = {

    // ================= ECE SECTIONS =================
    // Screenshot: 205346.png
    'ECE_A': {
      'Monday': ['CHE', 'CE', 'DEVC', 'NWA LAB', 'NWA LAB'],
      'Tuesday': ['CHE LAB', 'CHE LAB', 'BME', 'BME', 'CE'],
      'Wednesday': ['DEVC', 'CHE', 'NWA', 'EWS', 'EWS'],
      'Thursday': ['NWA', 'BME', 'SS', 'SS', 'BCE'],
      'Friday': ['CE LAB', 'CE LAB', 'BCE', 'CE', 'CHE'],
      'Saturday': ['DEVC', 'CE', 'NWA', 'NWA', 'EAA'],
    },
    
    // Screenshot: 205354.png
    'ECE_B': {
      'Monday': ['SS', 'CE', 'DEVC', 'EWS', 'EWS'],
      'Tuesday': ['BCE', 'CHE', 'DEVC', 'DEVC', 'NWA'],
      'Wednesday': ['CHE', 'CE', 'BME', 'NWA LAB', 'NWA LAB'],
      'Thursday': ['CHE LAB', 'CHE LAB', 'NWA', 'NWA', 'EAA'],
      'Friday': ['CE', 'BCE', 'NWA', 'CE LAB', 'CE LAB'],
      'Saturday': ['DEVC', 'CE', 'BME', 'BME', 'CHE'],
    },
    
    // Screenshot: 205402.png
    'ECE_C': {
      'Monday': ['CE', 'BME', 'SS', 'SS', 'BCE'],
      'Tuesday': ['DEVC', 'NWA', 'CE', 'NWA LAB', 'NWA LAB'],
      'Wednesday': ['CHE', 'DEVC', 'CE', 'DEVC', 'BME'],
      'Thursday': ['CE LAB', 'CE LAB', 'NWA', 'NWA', 'CHE'],
      'Friday': ['DEVC', 'BME', 'CHE', 'BCE', 'EWS'],
      'Saturday': ['CHE LAB', 'CHE LAB', 'NWA', 'NWA', 'EAA'],
    },
    
    // Screenshot: 205410.png (ECE-D / EEE-B shared timetable)
    'ECE_D': {
      'Monday': ['CHE', 'BCE', 'CE', 'CE', 'BME'],
      'Tuesday': ['SS', 'NWA/ECA', 'DEVC', 'CHE LAB', 'CHE LAB'],
      'Wednesday': ['DEVC', 'CHE', 'BCE', 'CE', 'CE'],
      'Thursday': ['EWS', 'EWS', 'NWA/ECA', 'NWA/ECA', 'EAA'],
      'Friday': ['DEVC', 'BME', 'CHE', 'NWA/ECA', 'NWA/ECA LAB'],
      'Saturday': ['NWA/ECA', 'CHE', 'CE', 'CE LAB', 'CE LAB'],
    },

    // ================= EEE SECTIONS =================
    // Screenshot: 205419.png
    'EEE_A': {
      'Monday': ['DEVC', 'CE', 'ECA', 'CHE LAB', 'CHE LAB'],
      'Tuesday': ['ECA', 'BCE', 'CHE', 'EWS', 'EWS'],
      'Wednesday': ['CE', 'DEVC', 'BME', 'ECA LAB', 'ECA LAB'],
      'Thursday': ['SS', 'ECA', 'CE', 'CE LAB', 'CE LAB'],
      'Friday': ['BCE', 'CE', 'CHE', 'CHE', 'DEVC'],
      'Saturday': ['BME', 'ECA', 'CHE', 'CHE', 'EAA'],
    },
    
    // EEE_B uses same timetable as ECE_D (Screenshot: 205410.png)
    'EEE_B': {
      'Monday': ['CHE', 'BCE', 'CE', 'CE', 'BME'],
      'Tuesday': ['SS', 'NWA/ECA', 'DEVC', 'CHE LAB', 'CHE LAB'],
      'Wednesday': ['DEVC', 'CHE', 'BCE', 'BCE', 'CE'],
      'Thursday': ['EWS', 'EWS', 'NWA/ECA', 'NWA/ECA', 'EAA'],
      'Friday': ['DEVC', 'BME', 'CHE', 'NWA/ECA', 'NWA/ECA LAB'],
      'Saturday': ['NWA/ECA', 'CHE', 'CE', 'CE LAB', 'CE LAB'],
    },

    // ================= ME SECTIONS =================
    // Screenshot: 205435.png
    'ME_A': {
      'Monday': ['CE LAB', 'CE LAB', 'BME', 'BME', 'SS'],
      'Tuesday': ['CE', 'BME', 'EM', 'EM LAB', 'EM LAB'],
      'Wednesday': ['DEVC', 'CHE', 'BCE', 'CHE', 'EM'],
      'Thursday': ['CHE', 'DEVC', 'BCE', 'BCE', 'CE'],
      'Friday': ['EWS', 'EWS', 'EM', 'EM', 'EAA'],
      'Saturday': ['DEVC', 'CE', 'CHE', 'CHE LAB', 'CHE LAB'],
    },
    
    // ME_B uses same timetable as CIVIL_A (Screenshot: 205425.png)
    'ME_B': {
      'Monday': ['BCE', 'EM', 'CE', 'CE', 'CHE'],
      'Tuesday': ['EM', 'BCE', 'DEVC', 'CE LAB', 'CE LAB'],
      'Wednesday': ['EWS', 'EWS', 'DEVC', 'DEVC', 'CE'],
      'Thursday': ['CHE', 'EM', 'BME', 'EM LAB', 'EM LAB'],
      'Friday': ['SS', 'EM', 'CHE', 'CHE LAB', 'CHE LAB'],
      'Saturday': ['DEVC', 'CE', 'BME', 'BME', 'EAA'],
    },

    // ================= CIVIL SECTION =================
    // Screenshot: 205425.png (CIVIL/ME-B shared timetable)
    'CIVIL_A': {
      'Monday': ['BCE', 'EM', 'CE', 'CE', 'CHE'],
      'Tuesday': ['EM', 'BCE', 'DEVC', 'CE LAB', 'CE LAB'],
      'Wednesday': ['EWS', 'EWS', 'DEVC', 'DEVC', 'CE'],
      'Thursday': ['CHE', 'EM', 'BME', 'EM LAB', 'EM LAB'],
      'Friday': ['SS', 'EM', 'CHE', 'CHE LAB', 'CHE LAB'],
      'Saturday': ['DEVC', 'CE', 'BME', 'BME', 'EAA'],
    },

    // ================= CSE (AI&ML) SECTIONS =================
    // Screenshot: 205442.png
    'CSE-AIML_A': {
      'Monday': ['DEVC', 'CE', 'BCE', 'BCE', 'DS'],
      'Tuesday': ['EWS', 'EWS', 'CE', 'CE', 'CHE'],
      'Wednesday': ['DEVC', 'CHE', 'DS LAB', 'DS LAB', 'BME'],
      'Thursday': ['DS', 'BCE', 'DEVC', 'CHE LAB', 'CHE LAB'],
      'Friday': ['CHE', 'BME', 'DS LAB', 'DS LAB', 'CE'],
      'Saturday': ['CE LAB', 'CE LAB', 'SS', 'SS', 'EAA'],
    },
    
    // Screenshot: 205449.png
    'CSE-AIML_B': {
      'Monday': ['DS', 'BME', 'CHE', 'CE LAB', 'CE LAB'],
      'Tuesday': ['CHE', 'DEVC', 'DS LAB', 'DS LAB', 'BCE'],
      'Wednesday': ['CHE LAB', 'CHE LAB', 'CE', 'CE', 'DS'],
      'Thursday': ['DEVC', 'CE', 'DS LAB', 'DS LAB', 'CHE'],
      'Friday': ['CE', 'BCE', 'BME', 'BME', 'EAA'],
      'Saturday': ['EWS', 'EWS', 'DEVC', 'DEVC', 'SS'],
    },
    
    // Screenshot: 205456.png
    'CSE-AIML_C': {
      'Monday': ['CHE LAB', 'CHE LAB', 'CE', 'CE', 'DEVC'],
      'Tuesday': ['BCE', 'BME', 'SS', 'SS', 'DS LAB'],
      'Wednesday': ['CE LAB', 'CE LAB', 'CHE', 'CHE', 'DS'],
      'Thursday': ['DEVC', 'CHE', 'BCE', 'EWS', 'EWS'],
      'Friday': ['DS LAB', 'CE', 'BME', 'BME', 'CHE'],
      'Saturday': ['DS', 'DEVC', 'CE', 'CE', 'EAA'],
    },
    
    // Screenshot: 205507.png
    'CSE-AIML_D': {
      'Monday': ['CHE', 'BCE', 'CE', 'CE', 'DS LAB'],
      'Tuesday': ['DS', 'CHE', 'SS', 'SS', 'BME'],
      'Wednesday': ['BCE', 'CE', 'DEVC', 'CE LAB', 'CE LAB'],
      'Thursday': ['DS LAB', 'CE', 'CHE', 'CHE', 'DEVC'],
      'Friday': ['CHE LAB', 'CHE LAB', 'DS', 'DS', 'EAA'],
      'Saturday': ['DEVC', 'BME', 'CE', 'EWS', 'EWS'],
    },

    // ================= CSE (CORE) SECTIONS =================
    // Screenshot: 205515.png
    'CSE_A': {
      'Monday': ['ITWS', 'ITWS', 'DS', 'DS', 'EEEW LAB'],
      'Tuesday': ['EG', 'EG', 'EP', 'EP', 'DS LAB'],
      'Wednesday': ['EEEW LAB', 'BEE B', 'DS LAB', 'DS LAB', 'DEVC'],
      'Thursday': ['BEE B', 'DEVC', 'BEE A', 'BEE A', 'EP'],
      'Friday': ['EP LAB', 'EP LAB', 'DS', 'DS', 'EAA'],
      'Saturday': ['SS', 'DEVC', 'BEE A', 'EG', 'EG'],
    },
    
    // Screenshot: 205522.png
    'CSE_B': {
      'Monday': ['BEE A', 'DEVC', 'DS', 'ITWS', 'ITWS'],
      'Tuesday': ['EG', 'EG', 'EP', 'EP', 'DS LAB'],
      'Wednesday': ['BEE B', 'BEE A', 'DS LAB', 'DS LAB', 'DEVC'],
      'Thursday': ['EG', 'EG', 'SS', 'SS', 'EEEW LAB'],
      'Friday': ['DS', 'BEE B', 'DEVC', 'EP LAB', 'EP LAB'],
      'Saturday': ['EEEW LAB', 'DS', 'EP', 'EP', 'EAA'],
    },
    
    // Screenshot: 205528.png
    'CSE_C': {
      'Monday': ['EP LAB', 'EP LAB', 'DEVC', 'DEVC', 'DS'],
      'Tuesday': ['EP', 'BEE B', 'EEEW LAB', 'EEEW LAB', 'SS'],
      'Wednesday': ['EG', 'EG', 'DEVC', 'DEVC', 'DS LAB'],
      'Thursday': ['BEE B', 'BEE A', 'DS LAB', 'DS LAB', 'EP'],
      'Friday': ['EEEW LAB', 'DS', 'BEE A', 'BEE A', 'EAA'],
      'Saturday': ['EG', 'EG', 'DS', 'DS', 'ITWS'],
    },
    
    // Screenshot: 205535.png
    'CSE_D': {
      'Monday': ['EEEW LAB', 'BEE B', 'EP', 'EP', 'DS'],
      'Tuesday': ['EG', 'EG', 'DS LAB', 'DS LAB', 'DEVC'],
      'Wednesday': ['BEE A', 'DS', 'EP', 'EP LAB', 'EP LAB'],
      'Thursday': ['SS', 'BEE A', 'BEE B', 'BEE B', 'DS LAB'],
      'Friday': ['EG', 'EG', 'DS', 'EP', 'EEEW LAB'],
      'Saturday': ['ITWS', 'ITWS', 'DEVC', 'DEVC', 'EAA'],
    },
    
    // Screenshot: 205542.png
    'CSE_E': {
      'Monday': ['DS', 'BEE B', 'EEEW LAB', 'EEEW LAB', 'DEVC'],
      'Tuesday': ['EP', 'DS', 'DS LAB', 'DS LAB', 'BEE A'],
      'Wednesday': ['EG', 'EG', 'DS LAB', 'DS LAB', 'SS'],
      'Thursday': ['EEEW LAB', 'DEVC', 'EP', 'EP ', 'EAA'],
      'Friday': ['BEE B', 'DS', 'DEVC', 'DEVC', 'ITWS'],
      'Saturday': ['EP LAB', 'EP LAB', 'BEE A', 'EG ', 'EG'],
    },

    // ================= CSE (DS) SECTIONS =================
    // Screenshot: 205601.png
    'CSE-DS_A': {
      'Monday': ['BEE A', 'DS', 'DEVC', 'DEVC', 'EP'],
      'Tuesday': ['EEEW LAB', 'DEVC', 'BEE A', 'ITWS', 'ITWS'],
      'Wednesday': ['EP LAB', 'EP LAB', 'DS LAB', 'DS', 'BEE B'],
      'Thursday': ['EG', 'EG', 'EEEW LAB', 'EEEW LAB', 'EAA'],
      'Friday': ['BEE B', 'DEVC', 'DS LAB', 'DS LAB', 'SS'],
      'Saturday': ['EG', 'EG', 'EP', 'EP ', 'DS'],
    },
    
    // Screenshot: 205609.png
    'CSE-DS_B': {
      'Monday': ['BEE B', 'DEVC', 'EP', 'EG', 'EG'],
      'Tuesday': ['DS', 'BEE B', 'DS LAB', 'DS LAB', 'EEEW LAB'],
      'Wednesday': ['DS LAB', 'DEVC', 'BEE A', 'BEE A', 'EP'],
      'Thursday': ['EG', 'EG', 'DS', 'DS', 'EEEW LAB'],
      'Friday': ['ITWS', 'ITWS', 'DEVC', 'DEVC', 'EAA'],
      'Saturday': ['SS', 'BEE A', 'EP', 'EP LAB ', 'EP LAB'],
    },
    
    // Screenshot: 205617.png (DS-C section, R-20 regulation)
    'CSE-DS_C': {
      'Monday': ['DEVC', 'BEE B', 'DS LAB', 'DS LAB', 'BEE A'],
      'Tuesday': ['EP LAB', 'EP LAB', 'BEE B', 'EG', 'EG'],
      'Wednesday': ['DS', 'BEE A', 'SS', 'SS', 'EEEW LAB'],
      'Thursday': ['ITWS', 'ITWS', 'EP', 'EP ', 'DS'],
      'Friday': ['EG', 'EG', 'DEVC', 'DEVC', 'EAA'],
      'Saturday': ['DS LAB', 'BEE B', 'EEEW LAB', 'EEEW LAB', 'EP'],
    },
    
    // Screenshot: 205550.png (CSE-F / DS-D shared timetable)
    'CSE-DS_D': {
      'Monday': ['EG', 'EG', 'EP', 'EP ', 'DEVC'],
      'Tuesday': ['BEE A', 'DS', 'DS LAB', 'DS LAB', 'SS'],
      'Wednesday': ['DEVC', 'BEE A', 'EP', 'EP ', 'DS LAB'],
      'Thursday': ['EP LAB', 'EP LAB', 'BEE B', 'ITWS', 'ITWS'],
      'Friday': ['BEE B', 'DS', 'EEEW LAB', 'EEEW LAB', 'EAA'],
      'Saturday': ['EG', 'EG', 'DS', 'DS', 'EEEW LAB'],
    },
    
    // CSE_F uses same timetable as CSE-DS_D
    'CSE_F': {
      'Monday': ['EG', 'EG', 'EP', 'EP ', 'DEVC'],
      'Tuesday': ['BEE A', 'DS', 'DS LAB', 'DS LAB', 'SS'],
      'Wednesday': ['DEVC', 'BEE A', 'EP', 'EP ', 'DS LAB'],
      'Thursday': ['EP LAB', 'EP LAB', 'BEE B', 'ITWS', 'ITWS'],
      'Friday': ['BEE B', 'DS', 'EEEW LAB', 'EEEW LAB', 'EAA'],
      'Saturday': ['EG', 'EG', 'DS', 'DS', 'EEEW LAB'],
    },

    // ================= CSE (CS) SECTIONS =================
    // Screenshot: 205625.png
    'CSE-CS_A': {
      'Monday': ['BEE A', 'DS', 'DEVC', 'EP LAB', 'EP LAB'],
      'Tuesday': ['ITWS', 'ITWS', 'BEE A', 'EG', 'EG'],
      'Wednesday': ['BEE B', 'DEVC', 'SS', 'SS', 'DS LAB'],
      'Thursday': ['EP', 'BEE B', 'EEEW LAB', 'EEEW LAB', 'DEVC'],
      'Friday': ['EG', 'EG', 'DS', 'DS', 'EAA'],
      'Saturday': ['EP', 'DS', 'DS LAB', 'DS LAB', 'EEEW LAB'],
    },
    
    // Screenshot: 205632.png
    'CSE-CS_B': {
      'Monday': ['DS', 'DEVC', 'BEE A', 'EG', 'EG'],
      'Tuesday': ['BEE A', 'DEVC', 'EP', 'EP LAB', 'EP LAB'],
      'Wednesday': ['ITWS', 'ITWS', 'EEEW LAB', 'EEEW LAB', 'DS'],
      'Thursday': ['BEE B', 'EP', 'DEVC', 'DEVC', 'EAA'],
      'Friday': ['EG', 'EG', 'SS', 'SS', 'DS LAB'],
      'Saturday': ['EP', 'BEE B', 'EEEW LAB', 'EEEW LAB', 'DS LAB'],
    },
  };
}
