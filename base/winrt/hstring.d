module winrt.hstring;

import winrt.base;
import winrt.debugutils;

public import winrt.winstring;

HSTRING duplicate_string(HSTRING other)
{
	HSTRING result = null;
	auto hr = WindowsDuplicateString(other, &result);
	Debug.OK(hr);
	return result;
}

void delete_string(ref HSTRING str)
{
	auto hr = WindowsDeleteString(str);
	Debug.OK(hr);
}

HSTRING create_string(const(wchar)* value, uint length)
{
	HSTRING result = null;
	auto hr = WindowsCreateString(value, length, &result);
	Debug.OK(hr);
	return result;
}

bool embedded_null(HSTRING value)
{
	BOOL result = 0;
	auto hr = WindowsStringHasEmbeddedNull(value, &result);
	Debug.OK(hr);
	return 0 != result;
}

struct hstring
{
	// TODO: make this better by RefCounting

	this(this)
	{
		owned = false;
	}

	~this()
	{
		if (owned)
			delete_string(m_handle);
	}

	this(in wstring value)
	{
		this(cast(const(wchar_t)*) value.ptr, cast(size_t) value.length);
	}

	this(const(wchar_t)* value, in size_t size)
	{
		owned = true;
		m_handle = create_string(cast(const(wchar)*) value, size);
	}

	this(HSTRING val)
	{
		owned = false;
		m_handle = val;
	}

	void clear()
	{
		auto result = WindowsDeleteString(handle);
		Debug.OK(result);
	}

	size_t length() nothrow
	{
		return WindowsGetStringLen(m_handle);
	}

	const(wchar)[] array() nothrow
	{
		return ptr[0 .. length];
	}

	alias array this;

	HSTRING handle() nothrow
	{
		return m_handle;
	}

	const(wchar_t)* ptr() nothrow
	{
		return cast(const(wchar_t)*) WindowsGetStringRawBuffer(m_handle, null);
	}

package:
	bool owned;
	HSTRING m_handle;
}