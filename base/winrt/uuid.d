module winrt.uuid;

import core.sys.windows.windows : GUID;

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

wstring factoryNameOf(T)()
{
	foreach (attr; __traits(getAttributes, T))
		static if (is(typeof(attr) == WinrtFactory))
			return attr.name;
	assert(false, T.stringof ~ " is no factory or has no WinrtFactory attached to it!");
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

struct WinrtFactory
{
	wstring name;
}

enum winrtFactory(T) = WinrtFactory(winrtNameOf!T);
