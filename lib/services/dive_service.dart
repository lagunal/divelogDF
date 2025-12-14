import 'package:divelogtest/models/dive_session.dart';
import 'package:divelogtest/services/storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class DiveService {
  static final DiveService _instance = DiveService._internal();
  factory DiveService() => _instance;
  DiveService._internal();

  final _uuid = const Uuid();
  final _storageService = StorageService();
  List<DiveSession> _sessions = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadFromStorage();
    _isInitialized = true;
  }

  Future<void> _loadFromStorage() async {
    try {
      final data = await _storageService.loadDiveSessions();
      _sessions = data.map((json) => DiveSession.fromJson(json)).toList();
      _sessions.sort((a, b) => b.horaEntrada.compareTo(a.horaEntrada));
    } catch (e) {
      debugPrint('Error loading dive sessions from storage: $e');
      _sessions = [];
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final data = _sessions.map((session) => session.toJson()).toList();
      await _storageService.saveDiveSessions(data);
    } catch (e) {
      debugPrint('Error saving dive sessions to storage: $e');
      rethrow;
    }
  }

  Future<DiveSession> createDiveSession(DiveSession session) async {
    await initialize();
    
    final newSession = session.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _sessions.insert(0, newSession);
    await _saveToStorage();
    return newSession;
  }

  Future<List<DiveSession>> getAllDiveSessions() async {
    await initialize();
    return List.unmodifiable(_sessions);
  }

  Future<DiveSession?> getDiveSessionById(String id) async {
    await initialize();
    try {
      return _sessions.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<DiveSession>> getDiveSessionsByDateRange(DateTime start, DateTime end) async {
    await initialize();
    return _sessions.where((session) => 
      session.horaEntrada.isAfter(start.subtract(const Duration(days: 1))) && 
      session.horaEntrada.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  Future<List<DiveSession>> getDiveSessionsByLocation(String location) async {
    await initialize();
    return _sessions.where((session) => 
      session.lugarBuceo.toLowerCase().contains(location.toLowerCase())
    ).toList();
  }

  Future<List<DiveSession>> getDiveSessionsByOperator(String operator) async {
    await initialize();
    return _sessions.where((session) => 
      session.operadoraBuceo.toLowerCase().contains(operator.toLowerCase())
    ).toList();
  }

  Future<List<DiveSession>> getDiveSessionsByUserId(String userId) async {
    await initialize();
    return _sessions.where((session) => session.userId == userId).toList();
  }

  Future<DiveSession> updateDiveSession(DiveSession session) async {
    await initialize();
    
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index == -1) {
      throw Exception('Dive session not found');
    }
    
    final updatedSession = session.copyWith(updatedAt: DateTime.now());
    _sessions[index] = updatedSession;
    _sessions.sort((a, b) => b.horaEntrada.compareTo(a.horaEntrada));
    await _saveToStorage();
    return updatedSession;
  }

  Future<void> deleteDiveSession(String id) async {
    await initialize();
    
    final index = _sessions.indexWhere((session) => session.id == id);
    if (index == -1) {
      throw Exception('Dive session not found');
    }
    
    _sessions.removeAt(index);
    await _saveToStorage();
  }

  Future<void> loadSampleData(String userId) async {
    await initialize();
    
    if (_sessions.isNotEmpty) {
      debugPrint('Sample data not loaded: sessions already exist');
      return;
    }

    final sampleSessions = [
      DiveSession(
        id: _uuid.v4(),
        userId: userId,
        cliente: 'Juan Pérez',
        operadoraBuceo: 'Dive Paradise',
        direccionOperadora: 'Av. Costera 123, Cancún, México',
        lugarBuceo: 'Arrecife Palancar',
        tipoBuceo: 'Scuba',
        nombreBuzos: ['Juan Pérez', 'María González'],
        supervisorBuceo: 'Carlos Ramírez',
        // tablaBuceo: 'US Navy',
        //aparatoRespiratorio: 'Circuito Abierto',
        //presionCilindro: 200.0,
        //tipoTraje: 'Húmedo 3mm',
        //mezclaUtilizada: 'Aire (21% O2)',
        estadoMar: 2,
        visibilidad: 25.0,
        temperaturaSuperior: 28.0,
        temperaturaAgua: 26.0,
        corrienteAgua: 'Leve',
        tipoAgua: 'Salada',
        horaEntrada: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
        maximaProfundidad: 18.5,
        tiempoIntervaloSuperficie: 60.0,
        tiempoFondo: 35.0,
        inicioDescompresion: null,
        descompresionCompleta: null,
        tiempoTotalInmersion: 42.0,
        horaSalida: DateTime.now().subtract(const Duration(days: 5, hours: 1, minutes: 18)),
        descripcionTrabajo: 'Buceo recreativo para observación de vida marina',
        descompresionUtilizada: 'Ninguna',
        enfermedadLesion: null,
        tiempoSupervisionAcumulado: 2.5,
        tiempoBuceoAcumulado: 0.7,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      DiveSession(
        id: _uuid.v4(),
        userId: userId,
        cliente: 'Ana Martínez',
        operadoraBuceo: 'Ocean Explorers',
        direccionOperadora: 'Boulevard Marina 456, Playa del Carmen',
        lugarBuceo: 'Cenote Dos Ojos',
        tipoBuceo: 'Scuba',
        nombreBuzos: ['Ana Martínez', 'Pedro López', 'Sofia Hernández'],
        supervisorBuceo: 'Miguel Torres',
        //tablaBuceo: 'PADI RDP',
        //aparatoRespiratorio: 'Circuito Abierto',
        //presionCilindro: 200.0,
        //tipoTraje: 'Húmedo 5mm',
        //mezclaUtilizada: 'Nitrox 32',
        estadoMar: 0,
        visibilidad: 40.0,
        temperaturaSuperior: 27.0,
        temperaturaAgua: 25.0,
        corrienteAgua: 'Nula',
        tipoAgua: 'Dulce',
        horaEntrada: DateTime.now().subtract(const Duration(days: 12, hours: 3)),
        maximaProfundidad: 12.0,
        tiempoIntervaloSuperficie: 90.0,
        tiempoFondo: 50.0,
        inicioDescompresion: null,
        descompresionCompleta: null,
        tiempoTotalInmersion: 55.0,
        horaSalida: DateTime.now().subtract(const Duration(days: 12, hours: 2, minutes: 5)),
        descripcionTrabajo: 'Exploración de cavernas en cenote',
        descompresionUtilizada: 'Ninguna',
        enfermedadLesion: null,
        tiempoSupervisionAcumulado: 3.0,
        tiempoBuceoAcumulado: 0.92,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      DiveSession(
        id: _uuid.v4(),
        userId: userId,
        cliente: 'Roberto Sánchez',
        operadoraBuceo: 'Deep Blue Diving',
        direccionOperadora: 'Zona Hotelera Km 8, Cozumel',
        lugarBuceo: 'Santa Rosa Wall',
        tipoBuceo: 'Scuba',
        nombreBuzos: ['Roberto Sánchez', 'Laura Jiménez'],
        supervisorBuceo: 'Fernando Morales',
        //tablaBuceo: 'US Navy',
        //aparatoRespiratorio: 'Circuito Abierto',
        //presionCilindro: 200.0,
        //tipoTraje: 'Húmedo 3mm',
        //mezclaUtilizada: 'Aire (21% O2)',
        estadoMar: 3,
        visibilidad: 30.0,
        temperaturaSuperior: 29.0,
        temperaturaAgua: 27.0,
        corrienteAgua: 'Moderada',
        tipoAgua: 'Salada',
        horaEntrada: DateTime.now().subtract(const Duration(days: 20, hours: 4)),
        maximaProfundidad: 24.0,
        tiempoIntervaloSuperficie: 120.0,
        tiempoFondo: 30.0,
        inicioDescompresion: DateTime.now().subtract(const Duration(days: 20, hours: 3, minutes: 35)),
        descompresionCompleta: DateTime.now().subtract(const Duration(days: 20, hours: 3, minutes: 30)),
        tiempoTotalInmersion: 38.0,
        horaSalida: DateTime.now().subtract(const Duration(days: 20, hours: 3, minutes: 22)),
        descripcionTrabajo: 'Inmersión en pared con corriente',
        descompresionUtilizada: 'Parada de seguridad 5min a 5m',
        enfermedadLesion: null,
        tiempoSupervisionAcumulado: 4.2,
        tiempoBuceoAcumulado: 0.63,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];

    _sessions.addAll(sampleSessions);
    await _saveToStorage();
    debugPrint('Sample dive data loaded successfully (${sampleSessions.length} sessions)');
  }

  Future<Map<String, dynamic>> getStatistics(String userId) async {
    await initialize();
    final userSessions = await getDiveSessionsByUserId(userId);
    
    if (userSessions.isEmpty) {
      return {
        'totalDives': 0,
        'totalBottomTime': 0.0,
        'deepestDive': 0.0,
        'averageDepth': 0.0,
        'totalDiveTime': 0.0,
      };
    }

    final totalDives = userSessions.length;
    final totalBottomTime = userSessions.fold<double>(
      0.0, (sum, session) => sum + session.tiempoFondo
    );
    final deepestDive = userSessions.fold<double>(
      0.0, (max, session) => session.maximaProfundidad > max ? session.maximaProfundidad : max
    );
    final averageDepth = userSessions.fold<double>(
      0.0, (sum, session) => sum + session.maximaProfundidad
    ) / totalDives;
    final totalDiveTime = userSessions.fold<double>(
      0.0, (sum, session) => sum + session.tiempoTotalInmersion
    );

    return {
      'totalDives': totalDives,
      'totalBottomTime': totalBottomTime,
      'deepestDive': deepestDive,
      'averageDepth': averageDepth,
      'totalDiveTime': totalDiveTime,
    };
  }

  Future<List<String>> getUniqueLocations() async {
    await initialize();
    final locations = _sessions.map((s) => s.lugarBuceo).toSet().toList();
    locations.sort();
    return locations;
  }

  Future<List<String>> getUniqueOperators() async {
    await initialize();
    final operators = _sessions.map((s) => s.operadoraBuceo).toSet().toList();
    operators.sort();
    return operators;
  }
}
