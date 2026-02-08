// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOrderCollection on Isar {
  IsarCollection<Order> get orders => this.collection();
}

const OrderSchema = CollectionSchema(
  name: r'Order',
  id: 103494837486634173,
  properties: {
    r'cashierName': PropertySchema(
      id: 0,
      name: r'cashierName',
      type: IsarType.string,
    ),
    r'changeAmount': PropertySchema(
      id: 1,
      name: r'changeAmount',
      type: IsarType.double,
    ),
    r'customerName': PropertySchema(
      id: 2,
      name: r'customerName',
      type: IsarType.string,
    ),
    r'customerPhone': PropertySchema(
      id: 3,
      name: r'customerPhone',
      type: IsarType.string,
    ),
    r'fiscalDayNo': PropertySchema(
      id: 4,
      name: r'fiscalDayNo',
      type: IsarType.long,
    ),
    r'fiscalSignature': PropertySchema(
      id: 5,
      name: r'fiscalSignature',
      type: IsarType.string,
    ),
    r'isFiscalized': PropertySchema(
      id: 6,
      name: r'isFiscalized',
      type: IsarType.bool,
    ),
    r'items': PropertySchema(
      id: 7,
      name: r'items',
      type: IsarType.objectList,
      target: r'OrderItem',
    ),
    r'needsFiscalRetry': PropertySchema(
      id: 8,
      name: r'needsFiscalRetry',
      type: IsarType.bool,
    ),
    r'orderDate': PropertySchema(
      id: 9,
      name: r'orderDate',
      type: IsarType.dateTime,
    ),
    r'paymentCurrency': PropertySchema(
      id: 10,
      name: r'paymentCurrency',
      type: IsarType.string,
    ),
    r'paymentMethod': PropertySchema(
      id: 11,
      name: r'paymentMethod',
      type: IsarType.string,
    ),
    r'qrCodeData': PropertySchema(
      id: 12,
      name: r'qrCodeData',
      type: IsarType.string,
    ),
    r'receiptGlobalNo': PropertySchema(
      id: 13,
      name: r'receiptGlobalNo',
      type: IsarType.long,
    ),
    r'shopId': PropertySchema(
      id: 14,
      name: r'shopId',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 15,
      name: r'status',
      type: IsarType.byte,
      enumMap: _OrderstatusEnumValueMap,
    ),
    r'tenderedAmount': PropertySchema(
      id: 16,
      name: r'tenderedAmount',
      type: IsarType.double,
    ),
    r'totalAmount': PropertySchema(
      id: 17,
      name: r'totalAmount',
      type: IsarType.double,
    ),
    r'zimraVerificationUrl': PropertySchema(
      id: 18,
      name: r'zimraVerificationUrl',
      type: IsarType.string,
    )
  },
  estimateSize: _orderEstimateSize,
  serialize: _orderSerialize,
  deserialize: _orderDeserialize,
  deserializeProp: _orderDeserializeProp,
  idName: r'id',
  indexes: {
    r'shopId': IndexSchema(
      id: 4502922094527709227,
      name: r'shopId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'shopId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'OrderItem': OrderItemSchema},
  getId: _orderGetId,
  getLinks: _orderGetLinks,
  attach: _orderAttach,
  version: '3.1.0+1',
);

int _orderEstimateSize(
  Order object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.cashierName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.customerName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.customerPhone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fiscalSignature;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.items;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[OrderItem]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              OrderItemSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  {
    final value = object.paymentCurrency;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.paymentMethod;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.qrCodeData;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.zimraVerificationUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _orderSerialize(
  Order object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cashierName);
  writer.writeDouble(offsets[1], object.changeAmount);
  writer.writeString(offsets[2], object.customerName);
  writer.writeString(offsets[3], object.customerPhone);
  writer.writeLong(offsets[4], object.fiscalDayNo);
  writer.writeString(offsets[5], object.fiscalSignature);
  writer.writeBool(offsets[6], object.isFiscalized);
  writer.writeObjectList<OrderItem>(
    offsets[7],
    allOffsets,
    OrderItemSchema.serialize,
    object.items,
  );
  writer.writeBool(offsets[8], object.needsFiscalRetry);
  writer.writeDateTime(offsets[9], object.orderDate);
  writer.writeString(offsets[10], object.paymentCurrency);
  writer.writeString(offsets[11], object.paymentMethod);
  writer.writeString(offsets[12], object.qrCodeData);
  writer.writeLong(offsets[13], object.receiptGlobalNo);
  writer.writeLong(offsets[14], object.shopId);
  writer.writeByte(offsets[15], object.status.index);
  writer.writeDouble(offsets[16], object.tenderedAmount);
  writer.writeDouble(offsets[17], object.totalAmount);
  writer.writeString(offsets[18], object.zimraVerificationUrl);
}

Order _orderDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Order();
  object.cashierName = reader.readStringOrNull(offsets[0]);
  object.changeAmount = reader.readDoubleOrNull(offsets[1]);
  object.customerName = reader.readStringOrNull(offsets[2]);
  object.customerPhone = reader.readStringOrNull(offsets[3]);
  object.fiscalDayNo = reader.readLongOrNull(offsets[4]);
  object.fiscalSignature = reader.readStringOrNull(offsets[5]);
  object.id = id;
  object.isFiscalized = reader.readBool(offsets[6]);
  object.items = reader.readObjectList<OrderItem>(
    offsets[7],
    OrderItemSchema.deserialize,
    allOffsets,
    OrderItem(),
  );
  object.needsFiscalRetry = reader.readBool(offsets[8]);
  object.orderDate = reader.readDateTime(offsets[9]);
  object.paymentCurrency = reader.readStringOrNull(offsets[10]);
  object.paymentMethod = reader.readStringOrNull(offsets[11]);
  object.qrCodeData = reader.readStringOrNull(offsets[12]);
  object.receiptGlobalNo = reader.readLongOrNull(offsets[13]);
  object.shopId = reader.readLongOrNull(offsets[14]);
  object.status =
      _OrderstatusValueEnumMap[reader.readByteOrNull(offsets[15])] ??
          OrderStatus.pending;
  object.tenderedAmount = reader.readDoubleOrNull(offsets[16]);
  object.totalAmount = reader.readDouble(offsets[17]);
  object.zimraVerificationUrl = reader.readStringOrNull(offsets[18]);
  return object;
}

P _orderDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readObjectList<OrderItem>(
        offset,
        OrderItemSchema.deserialize,
        allOffsets,
        OrderItem(),
      )) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    case 15:
      return (_OrderstatusValueEnumMap[reader.readByteOrNull(offset)] ??
          OrderStatus.pending) as P;
    case 16:
      return (reader.readDoubleOrNull(offset)) as P;
    case 17:
      return (reader.readDouble(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _OrderstatusEnumValueMap = {
  'pending': 0,
  'paid': 1,
  'synced': 2,
};
const _OrderstatusValueEnumMap = {
  0: OrderStatus.pending,
  1: OrderStatus.paid,
  2: OrderStatus.synced,
};

Id _orderGetId(Order object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _orderGetLinks(Order object) {
  return [];
}

void _orderAttach(IsarCollection<dynamic> col, Id id, Order object) {
  object.id = id;
}

extension OrderQueryWhereSort on QueryBuilder<Order, Order, QWhere> {
  QueryBuilder<Order, Order, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Order, Order, QAfterWhere> anyShopId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'shopId'),
      );
    });
  }
}

extension OrderQueryWhere on QueryBuilder<Order, Order, QWhereClause> {
  QueryBuilder<Order, Order, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Order, Order, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Order, Order, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Order, Order, QAfterWhereClause> idBetween(
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

  QueryBuilder<Order, Order, QAfterWhereClause> shopIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'shopId',
        value: [null],
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterWhereClause> shopIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'shopId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterWhereClause> shopIdEqualTo(int? shopId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'shopId',
        value: [shopId],
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterWhereClause> shopIdNotEqualTo(int? shopId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'shopId',
              lower: [],
              upper: [shopId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'shopId',
              lower: [shopId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'shopId',
              lower: [shopId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'shopId',
              lower: [],
              upper: [shopId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Order, Order, QAfterWhereClause> shopIdGreaterThan(
    int? shopId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'shopId',
        lower: [shopId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterWhereClause> shopIdLessThan(
    int? shopId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'shopId',
        lower: [],
        upper: [shopId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterWhereClause> shopIdBetween(
    int? lowerShopId,
    int? upperShopId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'shopId',
        lower: [lowerShopId],
        includeLower: includeLower,
        upper: [upperShopId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension OrderQueryFilter on QueryBuilder<Order, Order, QFilterCondition> {
  QueryBuilder<Order, Order, QAfterFilterCondition> cashierNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cashierName',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> cashierNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cashierName',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> cashierNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cashierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> cashierNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cashierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> cashierNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cashierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> cashierNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cashierName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> cashierNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cashierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> cashierNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cashierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> cashierNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cashierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> cashierNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cashierName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> cashierNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cashierName',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> cashierNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cashierName',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> changeAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'changeAmount',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> changeAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'changeAmount',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> changeAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> changeAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'changeAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> changeAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'changeAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> changeAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'changeAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'customerName',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'customerName',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customerName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customerName',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customerName',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerPhoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'customerPhone',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerPhoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'customerPhone',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerPhoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customerPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerPhoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customerPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerPhoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customerPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerPhoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customerPhone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerPhoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customerPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerPhoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customerPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerPhoneContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customerPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerPhoneMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customerPhone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerPhoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customerPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> customerPhoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customerPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalDayNoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fiscalDayNo',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalDayNoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fiscalDayNo',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalDayNoEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fiscalDayNo',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalDayNoGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fiscalDayNo',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalDayNoLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fiscalDayNo',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalDayNoBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fiscalDayNo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalSignatureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fiscalSignature',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalSignatureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fiscalSignature',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalSignatureEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fiscalSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalSignatureGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fiscalSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalSignatureLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fiscalSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalSignatureBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fiscalSignature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalSignatureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fiscalSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalSignatureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fiscalSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalSignatureContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fiscalSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalSignatureMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fiscalSignature',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> fiscalSignatureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fiscalSignature',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition>
      fiscalSignatureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fiscalSignature',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Order, Order, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Order, Order, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Order, Order, QAfterFilterCondition> isFiscalizedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFiscalized',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> itemsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'items',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> itemsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'items',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> itemsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> itemsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> itemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> itemsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> itemsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> itemsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> needsFiscalRetryEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needsFiscalRetry',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> orderDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> orderDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orderDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> orderDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orderDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> orderDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orderDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentCurrencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paymentCurrency',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentCurrencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paymentCurrency',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentCurrencyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentCurrencyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentCurrencyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentCurrencyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentCurrency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentCurrencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paymentCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentCurrencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paymentCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentCurrencyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paymentCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentCurrencyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paymentCurrency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentCurrencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentCurrency',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition>
      paymentCurrencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentCurrency',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentMethodIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paymentMethod',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentMethodIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paymentMethod',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentMethodEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentMethodGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentMethodLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentMethodBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentMethod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentMethodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentMethodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentMethodContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentMethodMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paymentMethod',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> paymentMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> qrCodeDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'qrCodeData',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> qrCodeDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'qrCodeData',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> qrCodeDataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qrCodeData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> qrCodeDataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qrCodeData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> qrCodeDataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qrCodeData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> qrCodeDataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qrCodeData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> qrCodeDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'qrCodeData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> qrCodeDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'qrCodeData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> qrCodeDataContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'qrCodeData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> qrCodeDataMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'qrCodeData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> qrCodeDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qrCodeData',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> qrCodeDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'qrCodeData',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> receiptGlobalNoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'receiptGlobalNo',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> receiptGlobalNoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'receiptGlobalNo',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> receiptGlobalNoEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptGlobalNo',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> receiptGlobalNoGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receiptGlobalNo',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> receiptGlobalNoLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receiptGlobalNo',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> receiptGlobalNoBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receiptGlobalNo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> shopIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'shopId',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> shopIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'shopId',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> shopIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shopId',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> shopIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shopId',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> shopIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shopId',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> shopIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shopId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> statusEqualTo(
      OrderStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> statusGreaterThan(
    OrderStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> statusLessThan(
    OrderStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> statusBetween(
    OrderStatus lower,
    OrderStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> tenderedAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tenderedAmount',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> tenderedAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tenderedAmount',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> tenderedAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tenderedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> tenderedAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tenderedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> tenderedAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tenderedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> tenderedAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tenderedAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> totalAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> totalAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> totalAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> totalAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition>
      zimraVerificationUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'zimraVerificationUrl',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition>
      zimraVerificationUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'zimraVerificationUrl',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> zimraVerificationUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zimraVerificationUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition>
      zimraVerificationUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zimraVerificationUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition>
      zimraVerificationUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zimraVerificationUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> zimraVerificationUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zimraVerificationUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition>
      zimraVerificationUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'zimraVerificationUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition>
      zimraVerificationUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'zimraVerificationUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition>
      zimraVerificationUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'zimraVerificationUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition> zimraVerificationUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'zimraVerificationUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition>
      zimraVerificationUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zimraVerificationUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Order, Order, QAfterFilterCondition>
      zimraVerificationUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'zimraVerificationUrl',
        value: '',
      ));
    });
  }
}

extension OrderQueryObject on QueryBuilder<Order, Order, QFilterCondition> {
  QueryBuilder<Order, Order, QAfterFilterCondition> itemsElement(
      FilterQuery<OrderItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'items');
    });
  }
}

extension OrderQueryLinks on QueryBuilder<Order, Order, QFilterCondition> {}

extension OrderQuerySortBy on QueryBuilder<Order, Order, QSortBy> {
  QueryBuilder<Order, Order, QAfterSortBy> sortByCashierName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashierName', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByCashierNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashierName', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByChangeAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAmount', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByChangeAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAmount', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByCustomerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByCustomerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByCustomerPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerPhone', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByCustomerPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerPhone', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByFiscalDayNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiscalDayNo', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByFiscalDayNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiscalDayNo', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByFiscalSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiscalSignature', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByFiscalSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiscalSignature', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByIsFiscalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFiscalized', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByIsFiscalizedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFiscalized', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByNeedsFiscalRetry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsFiscalRetry', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByNeedsFiscalRetryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsFiscalRetry', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByOrderDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderDate', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByOrderDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderDate', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByPaymentCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentCurrency', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByPaymentCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentCurrency', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByQrCodeData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCodeData', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByQrCodeDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCodeData', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByReceiptGlobalNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptGlobalNo', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByReceiptGlobalNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptGlobalNo', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByShopId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shopId', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByShopIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shopId', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByTenderedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenderedAmount', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByTenderedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenderedAmount', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByZimraVerificationUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zimraVerificationUrl', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> sortByZimraVerificationUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zimraVerificationUrl', Sort.desc);
    });
  }
}

extension OrderQuerySortThenBy on QueryBuilder<Order, Order, QSortThenBy> {
  QueryBuilder<Order, Order, QAfterSortBy> thenByCashierName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashierName', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByCashierNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashierName', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByChangeAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAmount', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByChangeAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAmount', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByCustomerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByCustomerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByCustomerPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerPhone', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByCustomerPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerPhone', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByFiscalDayNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiscalDayNo', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByFiscalDayNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiscalDayNo', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByFiscalSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiscalSignature', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByFiscalSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiscalSignature', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByIsFiscalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFiscalized', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByIsFiscalizedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFiscalized', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByNeedsFiscalRetry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsFiscalRetry', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByNeedsFiscalRetryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsFiscalRetry', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByOrderDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderDate', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByOrderDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderDate', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByPaymentCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentCurrency', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByPaymentCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentCurrency', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByQrCodeData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCodeData', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByQrCodeDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCodeData', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByReceiptGlobalNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptGlobalNo', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByReceiptGlobalNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptGlobalNo', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByShopId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shopId', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByShopIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shopId', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByTenderedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenderedAmount', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByTenderedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenderedAmount', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByZimraVerificationUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zimraVerificationUrl', Sort.asc);
    });
  }

  QueryBuilder<Order, Order, QAfterSortBy> thenByZimraVerificationUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zimraVerificationUrl', Sort.desc);
    });
  }
}

extension OrderQueryWhereDistinct on QueryBuilder<Order, Order, QDistinct> {
  QueryBuilder<Order, Order, QDistinct> distinctByCashierName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cashierName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByChangeAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeAmount');
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByCustomerName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByCustomerPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customerPhone',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByFiscalDayNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fiscalDayNo');
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByFiscalSignature(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fiscalSignature',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByIsFiscalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFiscalized');
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByNeedsFiscalRetry() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needsFiscalRetry');
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByOrderDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderDate');
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByPaymentCurrency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentCurrency',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByPaymentMethod(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentMethod',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByQrCodeData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qrCodeData', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByReceiptGlobalNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiptGlobalNo');
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByShopId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shopId');
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByTenderedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tenderedAmount');
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }

  QueryBuilder<Order, Order, QDistinct> distinctByZimraVerificationUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zimraVerificationUrl',
          caseSensitive: caseSensitive);
    });
  }
}

extension OrderQueryProperty on QueryBuilder<Order, Order, QQueryProperty> {
  QueryBuilder<Order, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Order, String?, QQueryOperations> cashierNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cashierName');
    });
  }

  QueryBuilder<Order, double?, QQueryOperations> changeAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeAmount');
    });
  }

  QueryBuilder<Order, String?, QQueryOperations> customerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customerName');
    });
  }

  QueryBuilder<Order, String?, QQueryOperations> customerPhoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customerPhone');
    });
  }

  QueryBuilder<Order, int?, QQueryOperations> fiscalDayNoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fiscalDayNo');
    });
  }

  QueryBuilder<Order, String?, QQueryOperations> fiscalSignatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fiscalSignature');
    });
  }

  QueryBuilder<Order, bool, QQueryOperations> isFiscalizedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFiscalized');
    });
  }

  QueryBuilder<Order, List<OrderItem>?, QQueryOperations> itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'items');
    });
  }

  QueryBuilder<Order, bool, QQueryOperations> needsFiscalRetryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needsFiscalRetry');
    });
  }

  QueryBuilder<Order, DateTime, QQueryOperations> orderDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderDate');
    });
  }

  QueryBuilder<Order, String?, QQueryOperations> paymentCurrencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentCurrency');
    });
  }

  QueryBuilder<Order, String?, QQueryOperations> paymentMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentMethod');
    });
  }

  QueryBuilder<Order, String?, QQueryOperations> qrCodeDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qrCodeData');
    });
  }

  QueryBuilder<Order, int?, QQueryOperations> receiptGlobalNoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiptGlobalNo');
    });
  }

  QueryBuilder<Order, int?, QQueryOperations> shopIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shopId');
    });
  }

  QueryBuilder<Order, OrderStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<Order, double?, QQueryOperations> tenderedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tenderedAmount');
    });
  }

  QueryBuilder<Order, double, QQueryOperations> totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }

  QueryBuilder<Order, String?, QQueryOperations>
      zimraVerificationUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zimraVerificationUrl');
    });
  }
}
