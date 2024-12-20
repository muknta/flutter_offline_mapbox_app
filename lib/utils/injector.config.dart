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
import 'package:flutter_offline_mapbox/data/db/storage_client.dart' as _i623;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

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
    await gh.lazySingletonAsync<_i623.StorageClient>(
      () {
        final i = _i623.StorageClient();
        return i.open().then((_) => i);
      },
      preResolve: true,
      dispose: (i) => i.close(),
    );
    gh.factory<_i174.CommentResourcesDao>(
        () => _i174.CommentResourcesDao(gh<_i623.StorageClient>()));
    gh.factory<_i456.PointsDao>(
        () => _i456.PointsDao(gh<_i623.StorageClient>()));
    gh.factory<_i14.UsersDao>(() => _i14.UsersDao(gh<_i623.StorageClient>()));
    gh.factory<_i713.CommentsDao>(
        () => _i713.CommentsDao(gh<_i623.StorageClient>()));
    return this;
  }
}
