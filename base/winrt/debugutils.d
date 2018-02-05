module winrt.debugutils;

import winrt.base;
import winrt.hstring;

import std.conv;
import std.string : strip;

extern (Windows) BOOL IsDebuggerPresent();
extern (Windows) void DebugBreak();

@uuid("82ba7092-4c88-427d-a7bc-16dd93feb67e")
interface IRestrictedErrorInfo : IUnknown
{
extern (Windows):
	HRESULT GetErrorDetails(wchar** description, HRESULT* error,
			wchar** restrictedDescription, wchar** capabilitySid);
	HRESULT GetReference(wchar** reference);
}

class HResultException : Exception
{
	this(HRESULT hresult, string file = __FILE__, size_t line = __LINE__)
	{
		import std.conv;

		code = hresult;
		if (hresult == S_OK)
		{
			super("Nothing wrong (S_OK)", file, line);
			return;
		}

		RoOriginateError(hresult, null);
		GetRestrictedErrorInfo(&info);

		super("HRESULT Fail: " ~ windowsMessage.to!string ~ " (0x" ~ hresult.to!string(16) ~ ")", file, line);
	}

	wstring windowsMessage()
	{
		import std.conv;
		import std.string;

		if (info)
		{
			HRESULT code;
			wchar* fallback, message, unused;
			if (info.GetErrorDetails(&fallback, &code, &message, &unused) == S_OK)
			{
				if (code == this.code)
				{
					if (message)
					{
						return message[0 .. SysStringLen(message)].strip.idup;
					}
					else
					{
						return fallback[0 .. SysStringLen(fallback)].strip.idup;
					}
				}
			}
		}

		return Debug.ErrorString(code);
	}

	HRESULT code;
	IRestrictedErrorInfo info;
}

struct Debug
{
	@disable this();

	static wstring ErrorString(HRESULT hr)
	{
		wchar* message;
		auto len = FormatMessageW(
				FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
				null, hr, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
				cast(wchar*)&message, 0, null);
		wstring ret = message[0 .. len].strip.idup;
		LocalFree(message);
		return ret;
	}

	static void Write(Char, Args...)(in Char[] message, Args args) nothrow
	{
		import std.format : format;
		import std.string : toStringz;

		try
		{
			OutputDebugStringA(format(message, args).toStringz);
		}
		catch (Exception)
		{
			OutputDebugStringA(message.toStringz);
		}
	}

	static void WriteLine(Char, Args...)(in Char[] message, Args args) nothrow
	{
		import std.format : format;
		import std.string : toStringz;

		try
		{
			OutputDebugStringA((format(message, args) ~ '\n').toStringz);
		}
		catch (Exception)
		{
			OutputDebugStringA((message ~ '\n').toStringz);
		}
	}

	/* ref HRESULT makes sure nobody uses Debug.OK code with side effects because it should be able to be removed in release builds */
	static void OK(ref HRESULT hr, string func = __PRETTY_FUNCTION__, string file = __FILE__, int line = __LINE__)
	{
		import std.conv;

		if (hr != S_OK)
		{
			auto ex = new HResultException(hr, file, line);
			WriteLine("HRESULT fail (0x%s / %s) in %s:%s in function %s",
					hr.to!string(16), ErrorString(hr).to!string, file, line, func);
			WriteLine("Exception: %s", ex);
			throw ex;
		}
	}

	static bool HasDebugger()
	{
		return !!IsDebuggerPresent();
	}

	static void Break()
	{
		DebugBreak();
	}

	static void Inspect(IInspectable inspectable)
	{
		ULONG iidCount;
		GUID* iids;
		HSTRING className;
		auto hr = inspectable.abi_GetIids(&iidCount, &iids);
		Debug.OK(hr);
		auto hr2 = inspectable.abi_GetRuntimeClassName(&className);
		Debug.OK(hr2);
		Debug.Write("IInspectable %s implementing ", hstring(className).array);
		foreach (i, iid; iids[0 .. iidCount])
		{
			if (i != 0)
				Debug.Write(", ");
			Debug.Write(guidToString(iid));
		}
		Debug.WriteLine("");
		Break();
	}
}