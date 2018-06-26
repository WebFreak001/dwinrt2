module winrt.uuid;

import core.sys.windows.windows : GUID;

import std.traits;

GUID uuid(string s)
{
	import std.uuid : parseUUID;

	auto uuid = parseUUID(s);
	GUID guid;
	guid.Data1 = uuid.data[3] | (uuid.data[2] << 8) | (uuid.data[1] << 16) | (uuid.data[0] << 24);
	guid.Data2 = uuid.data[5] | (uuid.data[4] << 8);
	guid.Data3 = uuid.data[7] | (uuid.data[6] << 8);
	guid.Data4 = uuid.data[8 .. 16];
	return guid;
}

string guidToString(GUID guid)
{
	import std.uuid : UUID;

	UUID uuid;
	uuid.data[0] = (guid.Data1 >> 24) & 0xFF;
	uuid.data[1] = (guid.Data1 >> 16) & 0xFF;
	uuid.data[2] = (guid.Data1 >> 8) & 0xFF;
	uuid.data[3] = (guid.Data1) & 0xFF;
	uuid.data[4] = (guid.Data2 >> 8) & 0xFF;
	uuid.data[5] = (guid.Data2) & 0xFF;
	uuid.data[6] = (guid.Data3 >> 8) & 0xFF;
	uuid.data[7] = (guid.Data3) & 0xFF;
	uuid.data[8 .. 16] = guid.Data4;
	return uuid.toString;
}

GUID uuidOf(T, bool throwIfNotThere = true)()
{
	GUID ret;
	foreach (attr; __traits(getAttributes, T))
	{
		static if (is(typeof(attr) == GUID))
			ret = attr;
	}
	static if (throwIfNotThere)
		if (ret == GUID.init)
			assert(false, T.stringof ~ " has no GUID attached to it! Use @uuid(...) to attach");
	return ret;
}

GUID uuidOfRt(T)()
{
	auto uuid = uuidOf!(T, false);
	if (uuid == GUID.init)
		uuid = uuidOfInstanced(T.stringof);
	return uuid;
}

struct WinrtName
{
	wstring name;
}

wstring winrtNameOf(T)()
{
	foreach (attr; __traits(getAttributes, T))
		static if (is(typeof(attr) == WinrtName))
			return attr.name;

	import std.conv;
	import std.string;
	import std.traits;

	string ret = fullyQualifiedName!T;
	auto idx = ret.lastIndexOf('.');
	if (ret[idx + 1] == 'I')
		return (ret[0 .. idx + 1] ~ ret[idx + 2 .. $]).to!wstring;
	else
		return ret.to!wstring;
}

struct WinrtFactory(Factory)
{
}

/// Returns the class holding a WinrtFactory in the inheritance tree.
template winrtFactoryClassOf(Class)
{
	alias factories = getUDAs!(Class, WinrtFactory);
	static if (factories.length == 0)
	{
		alias base = BaseTypeTuple!Class;
		static if (base.length == 0)
			static assert(false, "Could not find factory on class");
		else
			alias winrtFactoryClassOf = winrtFactoryClassOf!(base[0]);
	}
	else static if (factories.length == 1)
		alias winrtFactoryClassOf = Class;
	else
		static assert(false, "Multiple factories attached to " ~ Class.stringof);
}

template winrtFactoryOf(Class)
{
	alias factories = getUDAs!(Class, WinrtFactory);
	static if (factories.length == 0)
		static assert(false, "No factory attached to " ~ Class.stringof);
	else static if (factories.length == 1 && is(factories[0] : WinrtFactory!U, U))
		alias winrtFactoryOf = U;
	else
		static assert(false, "Multiple factories attached to " ~ Class.stringof);
}
