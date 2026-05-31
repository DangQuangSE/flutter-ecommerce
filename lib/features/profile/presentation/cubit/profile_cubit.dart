import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileInitial());

  // TODO: inject ProfileRepository and implement loadProfile()
}
