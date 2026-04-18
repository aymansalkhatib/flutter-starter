// ignore_for_file: avoid_print

import 'dart:io';

/// Saves the given `body` into a file with the specified `fileName` in the given `path`.
void saveFile(String path, String fileName, String body) {
  try {
    final filePath = '$path/$fileName';

    final directory = Directory(path);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      print('✅ Created directory: $path');
    }

    final file = File(filePath);
    file.writeAsStringSync(body);

    print('✅ File saved successfully: $filePath');
  } catch (e) {
    print('❌ Error saving file: $e');
  }
}

String _toPascalCase(String input) {
  return input
      .replaceAll(RegExp(r'[^\w]+'), ' ')
      .split(RegExp(r'[_\-\s]+'))
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join();
}

bool _isSnakeCase(String input) {
  final snakeCasePattern = RegExp(r'^[a-z]+(_[a-z]+)*$');
  return snakeCasePattern.hasMatch(input);
}

void main(List<String> args) {
  if (args.isEmpty) {
    print('❌ Error: No arguments provided.');
    print('Usage: dart main.dart <feature_name>');
    return;
  }

  final input = args[0];
  final className = _toPascalCase(input);
  final fileName = input;

  final featureDir = Directory('lib/features/$fileName');
  if (featureDir.existsSync()) {
    print(
        '⚠️ Directory "lib/features/$fileName" already exists. Operation aborted.');
    return;
  }

  if (!_isSnakeCase(input)) {
    print(
      '❌ Error: The provided name "$input" is not in valid snake_case format. Please use only lowercase letters and underscores.',
    );
    return;
  }

  // create empty entities folder
  Directory('lib/features/$fileName/domain/entities')
      .createSync(recursive: true);

  // create empty enums folder
  Directory('lib/features/$fileName/domain/enums').createSync(recursive: true);

  //
  saveFile(
    'lib/features/$fileName/data/datasources',
    '${fileName}_remote_datasource.dart',
    remoteDatasource
        .replaceAll('{{className}}', className)
        .replaceAll('{{fileName}}', fileName),
  );
  //
  saveFile(
    'lib/features/$fileName/data/models',
    '${fileName}_model.dart',
    model
        .replaceAll('{{className}}', className)
        .replaceAll('{{fileName}}', fileName),
  );
  //
  saveFile(
    'lib/features/$fileName/data/repositories',
    '${fileName}_repository_impl.dart',
    repositoriesImpl
        .replaceAll('{{className}}', className)
        .replaceAll('{{fileName}}', fileName),
  );
  //
  saveFile(
    'lib/features/$fileName/domain/params',
    '${fileName}_params.dart',
    params
        .replaceAll('{{className}}', className)
        .replaceAll('{{fileName}}', fileName),
  );
  //
  saveFile(
    'lib/features/$fileName/domain/repositories',
    '${fileName}_repository.dart',
    repositories
        .replaceAll('{{className}}', className)
        .replaceAll('{{fileName}}', fileName),
  );
  //
  saveFile(
    'lib/features/$fileName/domain/usecases',
    '${fileName}_usecases.dart',
    usecases
        .replaceAll('{{className}}', className)
        .replaceAll('{{fileName}}', fileName),
  );
  //
  saveFile(
    'lib/features/$fileName/presentation/controllers/$fileName',
    '${fileName}_cubit.dart',
    cubit
        .replaceAll('{{className}}', className)
        .replaceAll('{{fileName}}', fileName),
  );
  //
  saveFile(
    'lib/features/$fileName/presentation/controllers/$fileName',
    '${fileName}_state.dart',
    state
        .replaceAll('{{className}}', className)
        .replaceAll('{{fileName}}', fileName),
  );
  //
  saveFile(
    'lib/features/$fileName/presentation/screens',
    '${fileName}_screen.dart',
    screen
        .replaceAll('{{className}}', className)
        .replaceAll('{{fileName}}', fileName),
  );
  //
  saveFile(
    'lib/features/$fileName/presentation/widgets',
    '${fileName}_body.dart',
    body
        .replaceAll('{{className}}', className)
        .replaceAll('{{fileName}}', fileName),
  );
}

///
///
///
///
///  ⬇️ Snippets after removing entity usage
///
const remoteDatasource = '''
import 'package:dio/dio.dart';
import '../../../../core/usecases/usecases.dart';
import '../models/{{fileName}}_model.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/api_endpoints.dart';

abstract class {{className}}RemoteDatasource {
  Future<{{className}}Model> example(RequestParams params);
}

class {{className}}RemoteDatasourceImpl implements {{className}}RemoteDatasource {
  final ApiClient apiClient;

  {{className}}RemoteDatasourceImpl(this.apiClient);

  @override
  Future<{{className}}Model> example(RequestParams params) async {
    final Response response = await apiClient.post(
      ApiEndpoints.example,
      body: params.toJson(),
    );

    return {{className}}Model.fromJson(response.data);
  }
}''';

const model = r'''
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{fileName}}_model.freezed.dart';
part '{{fileName}}_model.g.dart';

@freezed
abstract class {{className}}Model with _${{className}}Model {
  const factory {{className}}Model({
    required String name,
  }) = _{{className}}Model;

  factory {{className}}Model.fromJson(Map<String, dynamic> json) =>
      _${{className}}ModelFromJson(json);
}''';

const repositoriesImpl = '''
import 'package:dio/dio.dart';
import '../../domain/params/{{fileName}}_params.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/server_failure.dart';
import '../../domain/repositories/{{fileName}}_repository.dart';
import '../datasources/{{fileName}}_remote_datasource.dart';
import '../models/{{fileName}}_model.dart';

class {{className}}RepositoryImpl implements {{className}}Repository {
  final {{className}}RemoteDatasource remoteDataSource;

  {{className}}RepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, {{className}}Model>> example({{className}}Params params) async {
    try {
      final ex = await remoteDataSource.example(params);
      return Right(ex);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}''';

const params = '''
import '../../../../core/usecases/usecases.dart';

class {{className}}Params extends RequestParams {
  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
''';

const repositories = '''
import '../params/{{fileName}}_params.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/{{fileName}}_model.dart';

abstract class {{className}}Repository {
  Future<Either<Failure, {{className}}Model>> example({{className}}Params params);
}''';

const usecases = '''
import '../../../../../core/utils/either.dart';
import '../../../../../core/errors/failure.dart';
import '../params/{{fileName}}_params.dart';
import '../repositories/{{fileName}}_repository.dart';
import '../../../../../core/usecases/usecases.dart';
import '../../data/models/{{fileName}}_model.dart';

class {{className}}Usecase extends Usecase<{{className}}Model, {{className}}Params> {
  final {{className}}Repository repository;
  {{className}}Usecase(this.repository);

  @override
  Future<Either<Failure, {{className}}Model>> call({{className}}Params params) {
    return repository.example(params);
  }
}''';

const cubit = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/errors/failure.dart';

part '{{fileName}}_state.dart';
part '{{fileName}}_cubit.freezed.dart';

class {{className}}Cubit extends Cubit<{{className}}State> {
  {{className}}Cubit() : super(const {{className}}State.initial());
}
''';

const state = r'''
part of '{{fileName}}_cubit.dart';

@freezed
class {{className}}State with _${{className}}State {
  const factory {{className}}State.initial() = _Initial;
  const factory {{className}}State.loading() = _Loading;
  const factory {{className}}State.success() = _Success;
  const factory {{className}}State.error(Failure message) = _Error;
}''';

const screen = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/components/custom_app_bar.dart';
import '../controllers/{{fileName}}/{{fileName}}_cubit.dart';
import '../widgets/{{fileName}}_body.dart';

class {{className}}Screen extends StatelessWidget {
  const {{className}}Screen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "{{className}}"),
      body: BlocBuilder<{{className}}Cubit, {{className}}State>(
        builder: (context, state) {
          return state.when(
            initial: () => const CircularProgressIndicator(),
            loading: () => const CircularProgressIndicator(),
            error: (failure) => const CircularProgressIndicator(),
            success: () => const {{className}}Body(),
          );
        },
      ),
    );
  }
}''';

const body = '''
import 'package:flutter/material.dart';

class {{className}}Body extends StatelessWidget {
  const {{className}}Body({super.key});
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}''';
