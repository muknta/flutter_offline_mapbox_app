// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_offline_mapbox/data/db/dao/comment_resources_dao.dart'
    as _i174;
import 'package:flutter_offline_mapbox/data/db/dao/comments_dao.dart' as _i713;
import 'package:flutter_offline_mapbox/data/db/dao/points_dao.dart' as _i456;
import 'package:flutter_offline_mapbox/data/db/dao/users_dao.dart' as _i14;
import 'package:flutter_offline_mapbox/data/db/sqlite_client.dart' as _i361;
import 'package:flutter_offline_mapbox/data/key_value/shared_prefs_client.dart'
    as _i870;
import 'package:flutter_offline_mapbox/domain/account_service.dart' as _i329;
import 'package:flutter_offline_mapbox/domain/auth_service.dart' as _i1066;
import 'package:flutter_offline_mapbox/domain/maps_metadata_service.dart'
    as _i650;
import 'package:flutter_offline_mapbox/domain/session_service.dart' as _i909;
import 'package:flutter_offline_mapbox/presentation/auth/auth_cubit.dart'
    as _i903;
import 'package:flutter_offline_mapbox/presentation/main/main_cubit.dart'
    as _i858;
import 'package:flutter_offline_mapbox/presentation/maps/maps_cubit.dart'
    as _i19;
import 'package:flutter_offline_mapbox/presentation/metadata/recent_points_cubit.dart'
    as _i356;
import 'package:flutter_offline_mapbox/utils/third_party_module.dart' as _i800;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final thirdPartyModule = _$ThirdPartyModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => thirdPartyModule.sharedPreferences,
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i361.SqliteClient>(
      () {
        final i = _i361.SqliteClient();
        return i.open().then((_) => i);
      },
      preResolve: true,
      dispose: (i) => i.close(),
    );
    gh.factory<_i870.SharedPrefsClient>(
        () => _i870.SharedPrefsClient(gh<_i460.SharedPreferences>()));
    gh.factory<_i174.CommentResourcesDao>(
        () => _i174.CommentResourcesDao(gh<_i361.SqliteClient>()));
    gh.factory<_i456.PointsDao>(
        () => _i456.PointsDao(gh<_i361.SqliteClient>()));
    gh.factory<_i14.UsersDao>(() => _i14.UsersDao(gh<_i361.SqliteClient>()));
    gh.factory<_i713.CommentsDao>(
        () => _i713.CommentsDao(gh<_i361.SqliteClient>()));
    await gh.singletonAsync<_i909.SessionService>(
      () {
        final i = _i909.SessionService(
          gh<_i14.UsersDao>(),
          gh<_i870.SharedPrefsClient>(),
        );
        return i.init().then((_) => i);
      },
      preResolve: true,
    );
    gh.factory<_i650.MapsMetadataService>(() => _i650.MapsMetadataService(
          gh<_i14.UsersDao>(),
          gh<_i713.CommentsDao>(),
          gh<_i174.CommentResourcesDao>(),
          gh<_i456.PointsDao>(),
          gh<_i909.SessionService>(),
          gh<_i870.SharedPrefsClient>(),
        ));
    gh.factory<_i19.MapsCubit>(() => _i19.MapsCubit(
          gh<_i650.MapsMetadataService>(),
          gh<_i909.SessionService>(),
          gh<_i870.SharedPrefsClient>(),
        ));
    gh.factory<_i329.AccountService>(() => _i329.AccountService(
          gh<_i14.UsersDao>(),
          gh<_i909.SessionService>(),
          gh<_i456.PointsDao>(),
          gh<_i713.CommentsDao>(),
          gh<_i174.CommentResourcesDao>(),
        ));
    gh.factory<_i1066.AuthService>(() => _i1066.AuthService(
          gh<_i14.UsersDao>(),
          gh<_i909.SessionService>(),
        ));
    gh.factory<_i858.MainCubit>(() => _i858.MainCubit(
          gh<_i1066.AuthService>(),
          gh<_i329.AccountService>(),
          gh<_i909.SessionService>(),
        ));
    gh.factory<_i356.RecentPointsCubit>(() => _i356.RecentPointsCubit(
          gh<_i650.MapsMetadataService>(),
          gh<_i909.SessionService>(),
        ));
    gh.factory<_i903.AuthCubit>(
        () => _i903.AuthCubit(gh<_i1066.AuthService>()));
    return this;
  }
}

class _$ThirdPartyModule extends _i800.ThirdPartyModule {}
