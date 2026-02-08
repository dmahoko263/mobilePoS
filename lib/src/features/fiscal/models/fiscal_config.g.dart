// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fiscal_config.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFiscalConfigCollection on Isar {
  IsarCollection<FiscalConfig> get fiscalConfigs => this.collection();
}

const FiscalConfigSchema = CollectionSchema(
  name: r'FiscalConfig',
  id: 5895837816316129538,
  properties: {
    r'activationKey': PropertySchema(
      id: 0,
      name: r'activationKey',
      type: IsarType.string,
    ),
    r'certificatePath': PropertySchema(
      id: 1,
      name: r'certificatePath',
      type: IsarType.string,
    ),
    r'currentFiscalDayNo': PropertySchema(
      id: 2,
      name: r'currentFiscalDayNo',
      type: IsarType.long,
    ),
    r'deviceId': PropertySchema(
      id: 3,
      name: r'deviceId',
      type: IsarType.long,
    ),
    r'deviceSerialNo': PropertySchema(
      id: 4,
      name: r'deviceSerialNo',
      type: IsarType.string,
    ),
    r'fiscalDayOpenTime': PropertySchema(
      id: 5,
      name: r'fiscalDayOpenTime',
      type: IsarType.dateTime,
    ),
    r'isFiscalDayOpen': PropertySchema(
      id: 6,
      name: r'isFiscalDayOpen',
      type: IsarType.bool,
    ),
    r'lastReceiptGlobalNo': PropertySchema(
      id: 7,
      name: r'lastReceiptGlobalNo',
      type: IsarType.long,
    ),
    r'previousReceiptHash': PropertySchema(
      id: 8,
      name: r'previousReceiptHash',
      type: IsarType.string,
    ),
    r'privateKeyPath': PropertySchema(
      id: 9,
      name: r'privateKeyPath',
      type: IsarType.string,
    )
  },
  estimateSize: _fiscalConfigEstimateSize,
  serialize: _fiscalConfigSerialize,
  deserialize: _fiscalConfigDeserialize,
  deserializeProp: _fiscalConfigDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _fiscalConfigGetId,
  getLinks: _fiscalConfigGetLinks,
  attach: _fiscalConfigAttach,
  version: '3.1.0+1',
);

int _fiscalConfigEstimateSize(
  FiscalConfig object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activationKey.length * 3;
  {
    final value = object.certificatePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.deviceSerialNo.length * 3;
  {
    final value = object.previousReceiptHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.privateKeyPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _fiscalConfigSerialize(
  FiscalConfig object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activationKey);
  writer.writeString(offsets[1], object.certificatePath);
  writer.writeLong(offsets[2], object.currentFiscalDayNo);
  writer.writeLong(offsets[3], object.deviceId);
  writer.writeString(offsets[4], object.deviceSerialNo);
  writer.writeDateTime(offsets[5], object.fiscalDayOpenTime);
  writer.writeBool(offsets[6], object.isFiscalDayOpen);
  writer.writeLong(offsets[7], object.lastReceiptGlobalNo);
  writer.writeString(offsets[8], object.previousReceiptHash);
  writer.writeString(offsets[9], object.privateKeyPath);
}

FiscalConfig _fiscalConfigDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FiscalConfig();
  object.activationKey = reader.readString(offsets[0]);
  object.certificatePath = reader.readStringOrNull(offsets[1]);
  object.currentFiscalDayNo = reader.readLong(offsets[2]);
  object.deviceId = reader.readLong(offsets[3]);
  object.deviceSerialNo = reader.readString(offsets[4]);
  object.fiscalDayOpenTime = reader.readDateTimeOrNull(offsets[5]);
  object.id = id;
  object.isFiscalDayOpen = reader.readBool(offsets[6]);
  object.lastReceiptGlobalNo = reader.readLong(offsets[7]);
  object.previousReceiptHash = reader.readStringOrNull(offsets[8]);
  object.privateKeyPath = reader.readStringOrNull(offsets[9]);
  return object;
}

P _fiscalConfigDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _fiscalConfigGetId(FiscalConfig object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _fiscalConfigGetLinks(FiscalConfig object) {
  return [];
}

void _fiscalConfigAttach(
    IsarCollection<dynamic> col, Id id, FiscalConfig object) {
  object.id = id;
}

extension FiscalConfigQueryWhereSort
    on QueryBuilder<FiscalConfig, FiscalConfig, QWhere> {
  QueryBuilder<FiscalConfig, FiscalConfig, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FiscalConfigQueryWhere
    on QueryBuilder<FiscalConfig, FiscalConfig, QWhereClause> {
  QueryBuilder<FiscalConfig, FiscalConfig, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FiscalConfigQueryFilter
    on QueryBuilder<FiscalConfig, FiscalConfig, QFilterCondition> {
  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      activationKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      activationKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      activationKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      activationKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activationKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      activationKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      activationKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      activationKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      activationKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activationKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      activationKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activationKey',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      activationKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activationKey',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      certificatePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'certificatePath',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      certificatePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'certificatePath',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      certificatePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'certificatePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      certificatePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'certificatePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      certificatePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'certificatePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      certificatePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'certificatePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      certificatePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'certificatePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      certificatePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'certificatePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      certificatePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'certificatePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      certificatePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'certificatePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      certificatePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'certificatePath',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      certificatePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'certificatePath',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      currentFiscalDayNoEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentFiscalDayNo',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      currentFiscalDayNoGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentFiscalDayNo',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      currentFiscalDayNoLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentFiscalDayNo',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      currentFiscalDayNoBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentFiscalDayNo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceSerialNoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceSerialNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceSerialNoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceSerialNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceSerialNoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceSerialNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceSerialNoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceSerialNo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceSerialNoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceSerialNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceSerialNoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceSerialNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceSerialNoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceSerialNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceSerialNoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceSerialNo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceSerialNoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceSerialNo',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      deviceSerialNoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceSerialNo',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      fiscalDayOpenTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fiscalDayOpenTime',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      fiscalDayOpenTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fiscalDayOpenTime',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      fiscalDayOpenTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fiscalDayOpenTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      fiscalDayOpenTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fiscalDayOpenTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      fiscalDayOpenTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fiscalDayOpenTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      fiscalDayOpenTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fiscalDayOpenTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      isFiscalDayOpenEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFiscalDayOpen',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      lastReceiptGlobalNoEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReceiptGlobalNo',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      lastReceiptGlobalNoGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReceiptGlobalNo',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      lastReceiptGlobalNoLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReceiptGlobalNo',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      lastReceiptGlobalNoBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReceiptGlobalNo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      previousReceiptHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'previousReceiptHash',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      previousReceiptHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'previousReceiptHash',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      previousReceiptHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousReceiptHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      previousReceiptHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousReceiptHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      previousReceiptHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousReceiptHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      previousReceiptHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousReceiptHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      previousReceiptHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'previousReceiptHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      previousReceiptHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'previousReceiptHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      previousReceiptHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousReceiptHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      previousReceiptHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousReceiptHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      previousReceiptHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousReceiptHash',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      previousReceiptHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousReceiptHash',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      privateKeyPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'privateKeyPath',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      privateKeyPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'privateKeyPath',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      privateKeyPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'privateKeyPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      privateKeyPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'privateKeyPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      privateKeyPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'privateKeyPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      privateKeyPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'privateKeyPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      privateKeyPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'privateKeyPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      privateKeyPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'privateKeyPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      privateKeyPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'privateKeyPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      privateKeyPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'privateKeyPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      privateKeyPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'privateKeyPath',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterFilterCondition>
      privateKeyPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'privateKeyPath',
        value: '',
      ));
    });
  }
}

extension FiscalConfigQueryObject
    on QueryBuilder<FiscalConfig, FiscalConfig, QFilterCondition> {}

extension FiscalConfigQueryLinks
    on QueryBuilder<FiscalConfig, FiscalConfig, QFilterCondition> {}

extension FiscalConfigQuerySortBy
    on QueryBuilder<FiscalConfig, FiscalConfig, QSortBy> {
  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy> sortByActivationKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationKey', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByActivationKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationKey', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByCertificatePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certificatePath', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByCertificatePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certificatePath', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByCurrentFiscalDayNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentFiscalDayNo', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByCurrentFiscalDayNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentFiscalDayNo', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByDeviceSerialNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceSerialNo', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByDeviceSerialNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceSerialNo', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByFiscalDayOpenTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiscalDayOpenTime', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByFiscalDayOpenTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiscalDayOpenTime', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByIsFiscalDayOpen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFiscalDayOpen', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByIsFiscalDayOpenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFiscalDayOpen', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByLastReceiptGlobalNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceiptGlobalNo', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByLastReceiptGlobalNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceiptGlobalNo', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByPreviousReceiptHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousReceiptHash', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByPreviousReceiptHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousReceiptHash', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByPrivateKeyPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privateKeyPath', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      sortByPrivateKeyPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privateKeyPath', Sort.desc);
    });
  }
}

extension FiscalConfigQuerySortThenBy
    on QueryBuilder<FiscalConfig, FiscalConfig, QSortThenBy> {
  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy> thenByActivationKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationKey', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByActivationKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationKey', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByCertificatePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certificatePath', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByCertificatePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certificatePath', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByCurrentFiscalDayNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentFiscalDayNo', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByCurrentFiscalDayNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentFiscalDayNo', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByDeviceSerialNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceSerialNo', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByDeviceSerialNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceSerialNo', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByFiscalDayOpenTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiscalDayOpenTime', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByFiscalDayOpenTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiscalDayOpenTime', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByIsFiscalDayOpen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFiscalDayOpen', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByIsFiscalDayOpenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFiscalDayOpen', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByLastReceiptGlobalNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceiptGlobalNo', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByLastReceiptGlobalNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceiptGlobalNo', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByPreviousReceiptHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousReceiptHash', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByPreviousReceiptHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousReceiptHash', Sort.desc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByPrivateKeyPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privateKeyPath', Sort.asc);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QAfterSortBy>
      thenByPrivateKeyPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privateKeyPath', Sort.desc);
    });
  }
}

extension FiscalConfigQueryWhereDistinct
    on QueryBuilder<FiscalConfig, FiscalConfig, QDistinct> {
  QueryBuilder<FiscalConfig, FiscalConfig, QDistinct> distinctByActivationKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activationKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QDistinct> distinctByCertificatePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'certificatePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QDistinct>
      distinctByCurrentFiscalDayNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentFiscalDayNo');
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QDistinct> distinctByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId');
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QDistinct> distinctByDeviceSerialNo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceSerialNo',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QDistinct>
      distinctByFiscalDayOpenTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fiscalDayOpenTime');
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QDistinct>
      distinctByIsFiscalDayOpen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFiscalDayOpen');
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QDistinct>
      distinctByLastReceiptGlobalNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReceiptGlobalNo');
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QDistinct>
      distinctByPreviousReceiptHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousReceiptHash',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FiscalConfig, FiscalConfig, QDistinct> distinctByPrivateKeyPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'privateKeyPath',
          caseSensitive: caseSensitive);
    });
  }
}

extension FiscalConfigQueryProperty
    on QueryBuilder<FiscalConfig, FiscalConfig, QQueryProperty> {
  QueryBuilder<FiscalConfig, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FiscalConfig, String, QQueryOperations> activationKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activationKey');
    });
  }

  QueryBuilder<FiscalConfig, String?, QQueryOperations>
      certificatePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'certificatePath');
    });
  }

  QueryBuilder<FiscalConfig, int, QQueryOperations>
      currentFiscalDayNoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentFiscalDayNo');
    });
  }

  QueryBuilder<FiscalConfig, int, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<FiscalConfig, String, QQueryOperations>
      deviceSerialNoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceSerialNo');
    });
  }

  QueryBuilder<FiscalConfig, DateTime?, QQueryOperations>
      fiscalDayOpenTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fiscalDayOpenTime');
    });
  }

  QueryBuilder<FiscalConfig, bool, QQueryOperations> isFiscalDayOpenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFiscalDayOpen');
    });
  }

  QueryBuilder<FiscalConfig, int, QQueryOperations>
      lastReceiptGlobalNoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReceiptGlobalNo');
    });
  }

  QueryBuilder<FiscalConfig, String?, QQueryOperations>
      previousReceiptHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousReceiptHash');
    });
  }

  QueryBuilder<FiscalConfig, String?, QQueryOperations>
      privateKeyPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'privateKeyPath');
    });
  }
}
