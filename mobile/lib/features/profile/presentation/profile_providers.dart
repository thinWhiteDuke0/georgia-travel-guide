import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_models.dart';
import '../../auth/data/auth_repository.dart';

final profileProvider = FutureProvider<Profile>((ref) => ref.watch(authRepositoryProvider).me());
