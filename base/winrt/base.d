module winrt.base;

public import core.sys.windows.windows;
public import core.sys.windows.com;
public import winrt.hstring;
public import winrt.uuid;

import winrt.debugutils;

pragma(lib, "User32");
pragma(lib, "windowsapp");
pragma(lib, "uuid");

enum ApartmentType
{
	singleThreaded,
	multiThreaded
}

enum TrustLevel
{
	BaseTrust,
	PartialTrust,
	FullTrust
}

struct EventRegistrationToken
{
	long value;
}

struct WinrtImplements
{
	string[] implements;
}

WinrtImplements winrtImplements(string[] implements...)
{
	return WinrtImplements(implements);
}

@uuid("c03f6a43-65a4-9818-987e-e0b810d2a6f2")
interface IAgileReference : IUnknown
{
extern (Windows):
	HRESULT abi_Resolve(REFIID riid, void** ppvObjectReference);
}

extern (Windows)
{
	HRESULT GetRestrictedErrorInfo(IRestrictedErrorInfo* info);
	HRESULT RoGetActivationFactory(HSTRING classId, const ref GUID iid, void** factory);
	HRESULT RoInitialize(uint type);
	BOOL RoOriginateError(HRESULT error, HSTRING message);
	void RoUninitialize();
	HRESULT SetRestrictedErrorInfo(IRestrictedErrorInfo info);
	HRESULT CoGetApartmentType(int* pAptType, int* pAptQualifier);
	HRESULT RoGetAgileReference(int options, REFIID riid, IUnknown pUnk,
			IAgileReference* ppAgileReference);
	HRESULT RoActivateInstance(HSTRING activatableClassId, IInspectable* instance);
}

pragma(inline, true) void init_apartment(in ApartmentType type = ApartmentType.multiThreaded)
{
	debug (DWinRT)
		Debug.WriteLine("RoInitialize %s", type);
	auto hr = RoInitialize(cast(uint) type);
	Debug.OK(hr);
}

pragma(inline, true) void uninit_apartment()
{
	debug (DWinRT)
		Debug.WriteLine("RoUninitialize");
	RoUninitialize();
}

@uuid("af86e2e0-b12d-4c6a-9c5a-d7aa65101e90")
interface IInspectable : IUnknown
{
extern (Windows):
	HRESULT abi_GetIids(ULONG* iidCount, GUID** iids);
	HRESULT abi_GetRuntimeClassName(HSTRING* className);
	HRESULT abi_GetTrustLevel(TrustLevel* trustLevel);
}

/// Internal extendable class implementing an IInspectable for WinRT.
abstract class RuntimeClass : ComObject, IInspectable
{
	Inspectable __inner;

extern (Windows):
	override HRESULT QueryInterface(const(IID)* riid, void** ppv)
	{
		if (*riid == IID_IUnknown)
		{
			*ppv = cast(void*) cast(IUnknown) this;
			AddRef();
			return S_OK;
		}
		else
		{
			return __inner.handle.QueryInterface(riid, ppv);
		}
	}

	override HRESULT abi_GetIids(ULONG* iidCount, GUID** iids)
	{
		return __inner.handle.abi_GetIids(iidCount, iids);
	}

	override HRESULT abi_GetRuntimeClassName(HSTRING* className)
	{
		return __inner.handle.abi_GetRuntimeClassName(className);
	}

	override HRESULT abi_GetTrustLevel(TrustLevel* trustLevel)
	{
		return __inner.handle.abi_GetTrustLevel(trustLevel);
	}
}

Inspectable roActivateInstance(hstring className)
{
	IInspectable inst;
	auto hr = RoActivateInstance(className.handle, &inst);
	Debug.OK(hr);
	return Inspectable(inst);
}

auto factory(Class)()
{
	alias T = winrtFactoryClassOf!Class;
	alias Factory = winrtFactoryOf!T;
	pragma(msg, Factory);
	return factory!Factory(hstring(winrtNameOf!T));
}

Factory factory(Factory)(hstring className)
{
	auto uuid = uuidOf!Factory;
	Factory inst;
	auto hr = RoGetActivationFactory(className.handle, uuid, cast(void**)&inst);
	Debug.OK(hr);
	return inst;
}

/// Struct used for inspecting an IInspectable
struct Inspectable
{
	IInspectable handle;

	bool has(T : IUnknown)() const
	{
		return hasUUID(uuidOf!T);
	}

	bool hasUUID(GUID uuid) const
	{
		ULONG count;
		GUID* iids;
		auto hr = (cast() handle).abi_GetIids(&count, &iids);
		Debug.OK(hr);
		foreach (iid; iids[0 .. count])
			if (iid == uuid)
				return true;
		return false;
	}

	T as(T : IUnknown)() const
	{
		debug assert(has!T);
		T ret;
		auto uuid = uuidOf!T;
		auto hr = (cast() handle).QueryInterface(&uuid, cast(void**)&ret);
		Debug.OK(hr);
		return ret;
	}
}

Inspectable make(T : RuntimeClass)(T obj)
{
	import std.traits : ParameterTypeTuple, PointerTarget;

	auto fac = factory!T;
	PointerTarget!(ParameterTypeTuple!(fac.abi_CreateInstance)[2]) inst;
	fac.abi_CreateInstance(cast(IInspectable)obj, &obj.__inner.handle, &inst);
	// casting down is safe & wanted here
	return Inspectable(inst);
}
