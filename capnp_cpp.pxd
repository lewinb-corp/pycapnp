# schema.capnp.cpp.pyx
# distutils: language = c++
# distutils: extra_compile_args = --std=c++11
# distutils: libraries = capnp
from schema_cpp cimport Node, Data, StructNode, EnumNode

from libc.stdint cimport *
ctypedef unsigned int uint

cdef extern from "kj/common.h" namespace "::kj":
    cdef cppclass Maybe[T]:
        pass

cdef extern from "capnp/schema.h" namespace "::capnp":
    cdef cppclass Schema:
        Node.Reader getProto()
        StructSchema asStruct() except +
        EnumSchema asEnum() except +
        Schema getDependency(uint64_t id) except +
        #InterfaceSchema asInterface() const;

    cdef cppclass MemberForward"::capnp::StructSchema::Member":
        pass

    cdef cppclass StructSchema(Schema):
        cppclass MemberList:
            uint size()
            MemberForward operator[](uint index)

        cppclass Union:
            StructNode.Union.Reader getProto()
            MemberList getMembers()
            MemberForward getMemberByName(char * name)

        cppclass Member:
            StructNode.Member.Reader getProto()
            StructSchema getContainingStruct()
            uint getIndex()
            MemberList getMembers()
            Union asUnion() except +

        Node.Reader getProto()
        MemberList getMembers()
        Member getMemberByName(char * name)

    cdef cppclass EnumSchema:
        cppclass Enumerant:
            EnumNode.Enumerant.Reader getProto()
            EnumSchema getContainingEnum()
            uint16_t getOrdinal()

        cppclass EnumerantList:
            uint size()
            Enumerant operator[](uint index)

        EnumerantList getEnumerants()
        Enumerant getEnumerantByName(char * name)
        Node.Reader getProto()

cdef extern from "capnp/schema-loader.h" namespace "::capnp":
    cdef cppclass SchemaLoader:
        SchemaLoader()
        Schema load(Node.Reader &) except +
        Schema get(uint64_t id) except +

cdef extern from "capnp/dynamic.h" namespace "::capnp":
    cdef cppclass DynamicValueForward"::capnp::DynamicValue":
        cppclass Reader:
            pass
        cppclass Builder:
            pass

    enum Type:
        TYPE_UNKNOWN "::capnp::DynamicValue::UNKNOWN"
        TYPE_VOID "::capnp::DynamicValue::VOID"
        TYPE_BOOL "::capnp::DynamicValue::BOOL"
        TYPE_INT "::capnp::DynamicValue::INT"
        TYPE_UINT "::capnp::DynamicValue::UINT"
        TYPE_FLOAT "::capnp::DynamicValue::FLOAT"
        TYPE_TEXT "::capnp::DynamicValue::TEXT"
        TYPE_DATA "::capnp::DynamicValue::DATA"
        TYPE_LIST "::capnp::DynamicValue::LIST"
        TYPE_ENUM "::capnp::DynamicValue::ENUM"
        TYPE_STRUCT "::capnp::DynamicValue::STRUCT"
        TYPE_UNION "::capnp::DynamicValue::UNION"
        TYPE_INTERFACE "::capnp::DynamicValue::INTERFACE"
        TYPE_OBJECT "::capnp::DynamicValue::OBJECT"

    cdef cppclass DynamicStruct:
        cppclass Reader:
            DynamicValueForward.Reader get(char *) except +ValueError
            bint has(char *) except +ValueError
        cppclass Builder:
            DynamicValueForward.Builder get(char *) except +ValueError
            bint has(char *) except +ValueError
            void set(char *, DynamicValueForward.Reader&) except +ValueError

cdef extern from "fixMaybe.h":
    StructSchema.Member fixMaybe(Maybe[StructSchema.Member]) except+

cdef extern from "capnp/dynamic.h" namespace "::capnp":
    cdef cppclass DynamicEnum:
        uint16_t getRaw()

    cdef cppclass DynamicUnion:
        cppclass Reader:
            DynamicValueForward.Reader get() except +ValueError
            Maybe[StructSchema.Member] which()
        cppclass Builder:
            DynamicValueForward.Builder get() except +ValueError
            Maybe[StructSchema.Member] which()
            void set(char *, DynamicValueForward.Reader&) except +ValueError

    cdef cppclass DynamicList:
        cppclass Reader:
            DynamicValueForward.Reader operator[](uint) except +ValueError
            uint size()
        cppclass Builder:
            DynamicValueForward.Builder operator[](uint) except +ValueError
            uint size()
            void set(uint index, DynamicValueForward.Reader& value)
            DynamicValueForward.Builder init(uint index, uint size)

    cdef cppclass DynamicValue:
        cppclass Reader:
            Reader()
            Reader(bint value)
            Reader(char value)
            Reader(short value)
            Reader(int value)
            Reader(long value)
            Reader(long long value)
            Reader(unsigned char value)
            Reader(unsigned short value)
            Reader(unsigned int value)
            Reader(unsigned long value)
            Reader(unsigned long long value)
            Reader(float value)
            Reader(double value)
            Reader(char* value)
            Reader(DynamicList.Reader& value)
            Reader(DynamicEnum value)
            Reader(DynamicStruct.Reader& value)
            Reader(DynamicUnion.Reader& value)
            Type getType()
            int64_t asInt"as<int64_t>"()
            uint64_t asUint"as<uint64_t>"()
            bint asBool"as<bool>"()
            double asDouble"as<double>"()
            char * asText"as<::capnp::Text>().cStr"()
            DynamicList.Reader asList"as<::capnp::DynamicList>"()
            DynamicStruct.Reader asStruct"as<::capnp::DynamicStruct>"()
            DynamicUnion.Reader asUnion"as<::capnp::DynamicUnion>"()
            DynamicEnum asEnum"as<::capnp::DynamicEnum>"()
            Data.Reader asData"as<::capnp::Data>"()
        cppclass Builder:
            Type getType()
            int64_t asInt"as<int64_t>"()
            uint64_t asUint"as<uint64_t>"()
            bint asBool"as<bool>"()
            double asDouble"as<double>"()
            char * asText"as<::capnp::Text>().cStr"()
            DynamicList.Builder asList"as<::capnp::DynamicList>"()
            DynamicStruct.Builder asStruct"as<::capnp::DynamicStruct>"()
            DynamicUnion.Builder asUnion"as<::capnp::DynamicUnion>"()
            DynamicEnum asEnum"as<::capnp::DynamicEnum>"()
            Data.Builder asData"as<::capnp::Data>"()