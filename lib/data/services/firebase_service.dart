import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/temple_model.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth Methods
  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google sign in error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Firestore Reference
  static CollectionReference get _usersRef => _firestore.collection('users');
  static CollectionReference get _templesRef => _firestore.collection('temples');
  static CollectionReference get _poojasRef => _firestore.collection('poojas');
  static CollectionReference get _eventsRef => _firestore.collection('events');
  static CollectionReference get _bookingsRef => _firestore.collection('bookings');
  static CollectionReference get _donationsRef => _firestore.collection('donations');
  static CollectionReference get _announcementsRef => _firestore.collection('announcements');

  // User Methods
  static Future<DocumentSnapshot> getUser(String uid) async {
    return await _usersRef.doc(uid).get();
  }

  static Future<void> createUser(String uid, Map<String, dynamic> data) async {
    await _usersRef.doc(uid).set(data);
  }

  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersRef.doc(uid).update(data);
  }

  static Future<List<DocumentSnapshot>> getAllUsers() async {
    final snapshot = await _usersRef.get();
    return snapshot.docs;
  }

  // Temple Methods
  static Future<String> addTemple(Map<String, dynamic> data) async {
    final docRef = await _templesRef.add(data);
    return docRef.id;
  }

  static Future<DocumentSnapshot> getTemple(String templeId) async {
    return await _templesRef.doc(templeId).get();
  }

  static Future<void> updateTemple(String templeId, Map<String, dynamic> data) async {
    await _templesRef.doc(templeId).update(data);
  }

  static Future<void> deleteTemple(String templeId) async {
    await _templesRef.doc(templeId).delete();
  }

  static Future<List<DocumentSnapshot>> getAllTemples() async {
    final snapshot = await _templesRef.where('isActive', isEqualTo: true).get();
    return snapshot.docs;
  }

  // Get temples where user is an admin
  static Future<List<DocumentSnapshot>> getTemplesByAdminEmail(String email) async {
    // First get all temples
    final temples = await _templesRef.where('isActive', isEqualTo: true).get();
    
    // Then filter by checking admins collection for this email
    final admins = await _firestore.collection('admins')
        .where('email', isEqualTo: email.toLowerCase())
        .get();
    
    final adminTempleIds = admins.docs.map((doc) => doc['templeId'] as String).toSet();
    
    return temples.docs.where((doc) => adminTempleIds.contains(doc.id)).toList();
  }

  static Future<List<TempleModel>> getTemplesByAdminEmailAsModels(String email) async {
    final docs = await getTemplesByAdminEmail(email);
    return docs.map((doc) => TempleModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  static Future<List<DocumentSnapshot>> getTemplesByDeity(String deity) async {
    final snapshot = await _templesRef
        .where('deity', isEqualTo: deity)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs;
  }

  // Pooja Methods
  static Future<String> addPooja(String templeId, Map<String, dynamic> data) async {
    final docRef = await _poojasRef.add({
      ...data,
      'templeId': templeId,
    });
    return docRef.id;
  }

  static Future<DocumentSnapshot> getPooja(String poojaId) async {
    return await _poojasRef.doc(poojaId).get();
  }

  static Future<void> updatePooja(String poojaId, Map<String, dynamic> data) async {
    await _poojasRef.doc(poojaId).update(data);
  }

  static Future<void> deletePooja(String poojaId) async {
    await _poojasRef.doc(poojaId).delete();
  }

  static Future<List<DocumentSnapshot>> getPoojasByTemple(String templeId) async {
    final snapshot = await _poojasRef
        .where('templeId', isEqualTo: templeId)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs;
  }

  // Helper methods to get data as List<Map>
  static Future<List<Map<String, dynamic>>> getPoojasByTempleAsMaps(String templeId) async {
    final docs = await getPoojasByTemple(templeId);
    return docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList();
  }

  static Future<List<Map<String, dynamic>>> getEventsByTempleAsMaps(String templeId) async {
    final docs = await getEventsByTemple(templeId);
    return docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList();
  }

  static Future<List<Map<String, dynamic>>> getAnnouncementsByTempleAsMaps(String templeId) async {
    final docs = await getAnnouncementsByTemple(templeId);
    return docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList();
  }

  static Future<List<DocumentSnapshot>> getAllPoojas() async {
    final snapshot = await _poojasRef.where('isActive', isEqualTo: true).get();
    return snapshot.docs;
  }

  // Event Methods
  static Future<String> addEvent(String templeId, Map<String, dynamic> data) async {
    final docRef = await _eventsRef.add({
      ...data,
      'templeId': templeId,
    });
    return docRef.id;
  }

  static Future<DocumentSnapshot> getEvent(String eventId) async {
    return await _eventsRef.doc(eventId).get();
  }

  static Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    await _eventsRef.doc(eventId).update(data);
  }

  static Future<void> deleteEvent(String eventId) async {
    await _eventsRef.doc(eventId).delete();
  }

  static Future<List<DocumentSnapshot>> getEventsByTemple(String templeId) async {
    final snapshot = await _eventsRef
        .where('templeId', isEqualTo: templeId)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs;
  }

  static Future<List<DocumentSnapshot>> getUpcomingEvents() async {
    final snapshot = await _eventsRef
        .where('isActive', isEqualTo: true)
        .where('eventDate', isGreaterThan: DateTime.now().toIso8601String())
        .orderBy('eventDate')
        .get();
    return snapshot.docs;
  }

  // Booking Methods
  static Future<String> createBooking(Map<String, dynamic> data) async {
    final docRef = await _bookingsRef.add(data);
    return docRef.id;
  }

  static Future<DocumentSnapshot> getBooking(String bookingId) async {
    return await _bookingsRef.doc(bookingId).get();
  }

  static Future<void> updateBookingStatus(String bookingId, String status) async {
    await _bookingsRef.doc(bookingId).update({'status': status});
  }

  static Future<List<DocumentSnapshot>> getBookingsByUser(String userId) async {
    final snapshot = await _bookingsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }

  static Future<List<DocumentSnapshot>> getBookingsByTemple(String templeId) async {
    final snapshot = await _bookingsRef
        .where('templeId', isEqualTo: templeId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }

  // Donation Methods
  static Future<String> createDonation(Map<String, dynamic> data) async {
    final docRef = await _donationsRef.add(data);
    return docRef.id;
  }

  static Future<DocumentSnapshot> getDonation(String donationId) async {
    return await _donationsRef.doc(donationId).get();
  }

  static Future<List<DocumentSnapshot>> getDonationsByUser(String userId) async {
    final snapshot = await _donationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }

  static Future<List<DocumentSnapshot>> getDonationsByTemple(String templeId) async {
    final snapshot = await _donationsRef
        .where('templeId', isEqualTo: templeId)
        .where('status', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }

  static Future<double> getTotalDonationsByTemple(String templeId) async {
    final snapshot = await _donationsRef
        .where('templeId', isEqualTo: templeId)
        .where('status', isEqualTo: 'completed')
        .get();
    
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc['amount'] ?? 0).toDouble();
    }
    return total;
  }

  // Announcement Methods
  static Future<String> createAnnouncement(String templeId, Map<String, dynamic> data) async {
    final docRef = await _announcementsRef.add({
      ...data,
      'templeId': templeId,
    });
    return docRef.id;
  }

  static Future<DocumentSnapshot> getAnnouncement(String announcementId) async {
    return await _announcementsRef.doc(announcementId).get();
  }

  static Future<void> updateAnnouncement(String announcementId, Map<String, dynamic> data) async {
    await _announcementsRef.doc(announcementId).update(data);
  }

  static Future<void> deleteAnnouncement(String announcementId) async {
    await _announcementsRef.doc(announcementId).delete();
  }

  static Future<List<DocumentSnapshot>> getAnnouncementsByTemple(String templeId) async {
    final snapshot = await _announcementsRef
        .where('templeId', isEqualTo: templeId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }

  // Dashboard Stats
  static Future<Map<String, dynamic>> getTempleStats(String templeId) async {
    final bookings = await getBookingsByTemple(templeId);
    final donations = await getDonationsByTemple(templeId);
    final poojas = await getPoojasByTemple(templeId);
    final events = await getEventsByTemple(templeId);

    double totalDonations = 0;
    for (var doc in donations) {
      totalDonations += (doc['amount'] ?? 0).toDouble();
    }

    return {
      'totalBookings': bookings.length,
      'totalDonations': totalDonations,
      'totalPoojas': poojas.length,
      'totalEvents': events.length,
    };
  }

  // Admin Methods
  static Future<Map<String, dynamic>?> getAdminByEmail(String email) async {
    final snapshot = await _firestore.collection('admins').where('email', isEqualTo: email.toLowerCase()).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return {...snapshot.docs.first.data() as Map<String, dynamic>, 'id': snapshot.docs.first.id};
  }

  static Future<String> addAdmin(String email, String name, String templeId, String templeName) async {
    final docRef = await _firestore.collection('admins').add({
      'email': email.toLowerCase(),
      'name': name,
      'templeId': templeId,
      'templeName': templeName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Future<void> removeAdmin(String adminId) async {
    await _firestore.collection('admins').doc(adminId).delete();
  }

  // Super Admin Methods
  static Future<Map<String, dynamic>?> getSuperAdminByEmail(String email) async {
    final snapshot = await _firestore.collection('superAdmins').where('email', isEqualTo: email.toLowerCase()).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return {...snapshot.docs.first.data() as Map<String, dynamic>, 'id': snapshot.docs.first.id};
  }

  static Future<bool> isSuperAdmin(String email) async {
    final admin = await getSuperAdminByEmail(email);
    return admin != null;
  }

  static Future<String> addSuperAdmin(String email, String name) async {
    final docRef = await _firestore.collection('superAdmins').add({
      'email': email.toLowerCase(),
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Future<void> removeSuperAdmin(String adminId) async {
    await _firestore.collection('superAdmins').doc(adminId).delete();
  }

  static Future<List<DocumentSnapshot>> getAllSuperAdmins() async {
    final snapshot = await _firestore.collection('superAdmins').get();
    return snapshot.docs;
  }

  static Future<void> seedSuperAdmin() async {
    final email = 'kollivenkatsai1802@gmail.com';
    final existing = await getSuperAdminByEmail(email);
    if (existing == null) {
      await addSuperAdmin(email, 'Super Admin');
    }
  }

  static Future<void> seedTemples() async {
    final temples = [
      {
        'name': 'Tirumala Tirupati Balaji Temple',
        'location': 'Tirupati, Andhra Pradesh',
        'deity': 'Lord Venkateswara',
        'address': 'Tirumala, Tirupati, Andhra Pradesh 517501',
        'phone': '+91 877 226 3301',
        'email': 'info@tirumala.org',
        'description': 'One of the most visited religious sites in the world, dedicated to Lord Venkateswara.',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'BAPS Temple',
        'location': 'Bartlett, Illinois, USA',
        'deity': 'Swaminarayan',
        'address': '1500 W. Bartlett Rd, Bartlett, IL 60103, USA',
        'phone': '+1 630-783-7855',
        'email': 'info@baps.org',
        'description': 'A stunning Hindu temple showcasing traditional Indian architecture in the heart of America.',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Meenakshi Temple',
        'location': 'Madurai, Tamil Nadu',
        'deity': 'Goddess Meenakshi',
        'address': 'Meenakshi Temple Rd, Madurai, Tamil Nadu 625001',
        'phone': '+91 452 234 4360',
        'email': 'meenakshitemple@tnhrdl.in',
        'description': 'Historic Hindu temple dedicated to Goddess Meenakshi and Lord Sundareswarar.',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Akshardham Temple',
        'location': 'New Delhi, India',
        'deity': 'Swaminarayan',
        'address': 'Nizzampuram, New Delhi 110092',
        'phone': '+91 11 2757 2388',
        'email': 'info@akshardham.com',
        'description': 'One of the largest Hindu temples in the world, showcasing millennia of traditional Hindu culture.',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Golden Temple (Harmandir Sahib)',
        'location': 'Amritsar, Punjab',
        'deity': 'Waheguru',
        'address': 'Golden Temple Rd, Amritsar, Punjab 143006',
        'phone': '+91 183 500 0601',
        'email': 'info@goldentemple.org',
        'description': 'The holiest Sikh gurdwara, known for its golden architecture and spiritual significance.',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Kedarnath Temple',
        'location': 'Kedarnath, Uttarakhand',
        'deity': 'Lord Shiva',
        'address': 'Kedarnath, Uttarakhand 246445',
        'phone': '+91 1362 260 203',
        'email': 'info@kedarnath.gov.in',
        'description': 'One of the twelve Jyotirlingas, located in the Himalayas at 3,583 m altitude.',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Siddhivinayak Temple',
        'location': 'Mumbai, Maharashtra',
        'deity': 'Lord Ganesha',
        'address': 'Siddhivinayak Temple, Prabhadevi, Mumbai 400028',
        'phone': '+91 22 2422 0126',
        'email': 'info@siddhivinayak.org',
        'description': 'One of the most revered temples in Mumbai, dedicated to Lord Ganesha.',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Vitthal Temple',
        'location': 'Pandharpur, Maharashtra',
        'deity': 'Lord Vithoba',
        'address': 'Vitthal Temple, Pandharpur, Maharashtra 415311',
        'phone': '+91 2186 230 021',
        'email': 'info@pandharpur.org',
        'description': 'Significant pilgrimage site dedicated to Lord Vithoba, visited by millions.',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    for (var temple in temples) {
      await _templesRef.add(temple);
    }
  }

  static Future<void> seedPoojas(String templeId) async {
    final poojas = [
      {
        'name': 'Suprabhatha Seva',
        'description': 'Morning wake-up ceremony for the deity',
        'timing': '4:00 AM - 5:00 AM',
        'price': 100.0,
        'duration': 60,
        'availableSlots': 100,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Thomtha Seva',
        'description': 'Food offering ceremony',
        'timing': '6:00 AM - 7:00 AM',
        'price': 150.0,
        'duration': 60,
        'availableSlots': 50,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Archana',
        'description': 'Special puja with 108 names of the deity',
        'timing': '8:00 AM - 12:00 PM',
        'price': 250.0,
        'duration': 30,
        'availableSlots': 30,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Sahasranamarchana',
        'description': 'Recitation of 1000 names',
        'timing': '9:00 AM - 11:00 AM',
        'price': 500.0,
        'duration': 120,
        'availableSlots': 20,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Kashaya Viniyoga',
        'description': 'Special ritual with sacred ash',
        'timing': '10:00 AM - 11:00 AM',
        'price': 350.0,
        'duration': 60,
        'availableSlots': 25,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    for (var pooja in poojas) {
      await _poojasRef.add({
        ...pooja,
        'templeId': templeId,
        'bookedSlots': 0,
      });
    }
  }
}
