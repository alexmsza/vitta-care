import 'package:vitta/features/family/domain/entities/service_request.dart';
import 'package:uuid/uuid.dart';

class MockDataService {
  static List<ServiceRequest> getOpenOpportunities() {
    return [
      ServiceRequest(
        id: const Uuid().v4(),
        familyId: 'family-1',
        date: DateTime.now().add(const Duration(days: 1)),
        duration: ServiceDuration.twelveHours,
        tags: ['Acamado', 'Alzheimer', 'Alta Complexidade'],
        status: RequestStatus.open,
        priceTotal: 240.00,
        createdAt: DateTime.now(),
        patientName: 'Sra. Maria Oliveira',
        description:
            'Paciente acamada, necessita de cuidados de higiene e administração de medicação.',
      ),
      ServiceRequest(
        id: const Uuid().v4(),
        familyId: 'family-2',
        date: DateTime.now().add(const Duration(days: 2)),
        duration: ServiceDuration.eightHours,
        tags: ['Lúcido', 'Gosta de Música'],
        status: RequestStatus.open,
        priceTotal: 120.00,
        createdAt: DateTime.now(),
        patientName: 'Sr. João Silva',
        description:
            'Paciente lúcido, gosta de conversar. Necessita companhia e monitoramento leve.',
      ),
      ServiceRequest(
        id: const Uuid().v4(),
        familyId: 'family-3',
        date: DateTime.now().add(const Duration(days: 3)),
        duration: ServiceDuration.twentyFourHours,
        tags: ['Pós-Cirúrgico', 'Alta Complexidade'],
        status: RequestStatus.open,
        priceTotal: 550.00,
        createdAt: DateTime.now(),
        patientName: 'Sra. Ana Pereira',
        description:
            'Pós-operatório de quadril. Necessita auxílio para locomoção e curativos.',
      ),
    ];
  }
}
