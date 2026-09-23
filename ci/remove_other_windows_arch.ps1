param(
	[Parameter(Mandatory = $true)]
	[ValidateSet("amd64", "arm64")]
	[string]$Architecture,

	[Parameter(Mandatory = $true)]
	[string]$Root
)

$root_path = (Resolve-Path -LiteralPath $Root).Path
$root_prefix = $root_path + [IO.Path]::DirectorySeparatorChar

function Remove-DirectoryInsideRoot {
	param([string]$Path)

	if (!(Test-Path -LiteralPath $Path)) {
		return
	}

	$full_path = [IO.Path]::GetFullPath($Path)
	if (!($full_path + [IO.Path]::DirectorySeparatorChar).StartsWith($root_prefix, [StringComparison]::OrdinalIgnoreCase)) {
		throw "Refusing to remove directory outside artifact root: $full_path"
	}

	Remove-Item -LiteralPath $full_path -Recurse -Force
}

function Remove-FileInsideRoot {
	param([string]$Path)

	if (!(Test-Path -LiteralPath $Path)) {
		return
	}

	$full_path = [IO.Path]::GetFullPath($Path)
	if (!$full_path.StartsWith($root_prefix, [StringComparison]::OrdinalIgnoreCase)) {
		throw "Refusing to remove file outside artifact root: $full_path"
	}

	Remove-Item -LiteralPath $full_path -Force
}

$other_arch = if ($Architecture -eq "amd64") { "arm64" } else { "amd64" }
$vendor_path = Join-Path $root_path "vendor"

if ($Architecture -eq "arm64") {
	# AMD64 vendor binaries retain their upstream paths rather than living
	# under an architecture directory. Keep their removal explicit.
	Get-Content -LiteralPath (Join-Path $PSScriptRoot "windows_amd64_vendor_files.txt") |
		Where-Object { $_ -ne "" -and !$_.StartsWith("#") } |
		ForEach-Object { Remove-FileInsideRoot (Join-Path $vendor_path $_) }
}

Get-ChildItem -LiteralPath $vendor_path -Directory -Recurse |
	Where-Object { $_.Name -eq $other_arch } |
	Sort-Object FullName -Descending |
	ForEach-Object { Remove-DirectoryInsideRoot $_.FullName }

Remove-DirectoryInsideRoot (Join-Path $root_path "bin\llvm\windows\$other_arch")

$llvm_path = Join-Path $root_path "bin\llvm\windows\$Architecture"
Remove-FileInsideRoot (Join-Path $llvm_path "LLVM-C.dll")
Remove-FileInsideRoot (Join-Path $llvm_path "LLVM-C.lib")
Remove-FileInsideRoot (Join-Path $llvm_path "lld-link.exe")
Remove-FileInsideRoot (Join-Path $llvm_path "wasm-ld.exe")

if ($Architecture -eq "arm64") {
	Remove-FileInsideRoot (Join-Path $root_path "bin\radlink.exe")
	Remove-FileInsideRoot (Join-Path $root_path "bin\RAD-LICENSE")
}

$other_wgpu_arch = if ($Architecture -eq "amd64") { "aarch64" } else { "x86_64" }
Remove-DirectoryInsideRoot (Join-Path $vendor_path "wgpu\lib\wgpu-windows-$other_wgpu_arch-msvc-release")
