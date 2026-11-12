"""Generate the dependency-free iOS project. Resource folders retain their hierarchy."""
from pathlib import Path
import hashlib
ROOT = Path(__file__).resolve().parent.parent

def ident(s):
    return hashlib.sha1(s.encode()).hexdigest()[:24].upper()

objects = []
def add(key, value):
    objects.append(f'{ident(key)} = {{ {value} }};')
    return ident(key)

sources = []
refs = []
for path in sorted((ROOT / 'Wortschatz').rglob('*.swift')):
    rel = path.relative_to(ROOT).as_posix()
    ref = add(rel, f'isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{rel}"; sourceTree = SOURCE_ROOT;')
    refs.append(ref)
    sources.append(add('build'+rel, f'isa = PBXBuildFile; fileRef = {ref};'))
resources = []
for path, kind in [('Wortschatz/Resources/PrivacyInfo.xcprivacy', 'text.xml'), ('lessons', 'folder'), ('site/lesson-template.html', 'text.html'), ('Wortschatz/Resources/Assets.xcassets', 'folder.assetcatalog')]:
    ref = add(path, f'isa = PBXFileReference; lastKnownFileType = {kind}; path = "{path}"; sourceTree = SOURCE_ROOT;')
    refs.append(ref)
    resources.append(add('build'+path, f'isa = PBXBuildFile; fileRef = {ref};'))
product = add('product', 'isa = PBXFileReference; explicitFileType = wrapper.application; path = Wortschatz.app; sourceTree = BUILT_PRODUCTS_DIR;')
products = add('products', f'isa = PBXGroup; name = Products; children = ({product},); sourceTree = "<group>";')
main = add('main', f'isa = PBXGroup; children = ({",".join(refs + [products])},); sourceTree = "<group>";')
src = add('sources', f'isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({",".join(sources)},); runOnlyForDeploymentPostprocessing = 0;')
res = add('resources', f'isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ({",".join(resources)},); runOnlyForDeploymentPostprocessing = 0;')
frameworks = add('frameworks', 'isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0;')
for scope in ['project', 'target']:
    configs = []
    for name in ['Debug', 'Release']:
        settings = 'SDKROOT = iphoneos; IPHONEOS_DEPLOYMENT_TARGET = 18.0; CLANG_ENABLE_MODULES = YES; SWIFT_VERSION = 5.0;'
        if scope == 'target':
            settings += ' PRODUCT_NAME = Wortschatz; PRODUCT_BUNDLE_IDENTIFIER = com.jian.wortschatz; TARGETED_DEVICE_FAMILY = "1,2"; GENERATE_INFOPLIST_FILE = YES; INFOPLIST_KEY_CFBundleDisplayName = Wortschatz; INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.education"; INFOPLIST_KEY_UILaunchScreen_Generation = YES; INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES; INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"; INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"; CODE_SIGN_STYLE = Automatic; SWIFT_EMIT_LOC_STRINGS = YES;'
        if scope == 'target':
            settings += ' ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;'
        if name == 'Debug':
            settings += ' SWIFT_ACTIVE_COMPILATION_CONDITIONS = "$(inherited) DEBUG"; SWIFT_OPTIMIZATION_LEVEL = "-Onone"; DEBUG_INFORMATION_FORMAT = dwarf;'
        else:
            settings += ' SWIFT_OPTIMIZATION_LEVEL = "-O"; DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";'
        configs.append(add(scope+name, f'isa = XCBuildConfiguration; name = {name}; buildSettings = {{ {settings} }};'))
    add(scope+'configs', f'isa = XCConfigurationList; buildConfigurations = ({",".join(configs)},); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;')
target = add('target', f'isa = PBXNativeTarget; buildConfigurationList = {ident("targetconfigs")}; buildPhases = ({src},{frameworks},{res},); buildRules = (); dependencies = (); name = Wortschatz; productName = Wortschatz; productReference = {product}; productType = "com.apple.product-type.application";')
ui_ref = add('uitestfile', 'isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Tests/UITests/StudyFlowTests.swift; sourceTree = SOURCE_ROOT;')
ui_build = add('uitestbuild', f'isa = PBXBuildFile; fileRef = {ui_ref};')
ui_sources = add('uitestsources', f'isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({ui_build},); runOnlyForDeploymentPostprocessing = 0;')
ui_product = add('uitestproduct', 'isa = PBXFileReference; explicitFileType = wrapper.cfbundle; path = WortschatzUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR;')
ui_configs = []
for name in ['Debug', 'Release']:
    ui_configs.append(add('ui'+name, f'isa = XCBuildConfiguration; name = {name}; buildSettings = {{ SDKROOT = iphoneos; IPHONEOS_DEPLOYMENT_TARGET = 18.0; SWIFT_VERSION = 5.0; GENERATE_INFOPLIST_FILE = YES; PRODUCT_NAME = WortschatzUITests; PRODUCT_BUNDLE_IDENTIFIER = com.jian.wortschatz.uitests; TEST_TARGET_NAME = Wortschatz; TARGETED_DEVICE_FAMILY = "1,2"; CODE_SIGN_STYLE = Automatic; }};'))
ui_configlist = add('uiconfigs', f'isa = XCConfigurationList; buildConfigurations = ({",".join(ui_configs)},); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;')
proxy = add('proxy', f'isa = PBXContainerItemProxy; containerPortal = {ident("project")}; proxyType = 1; remoteGlobalIDString = {target}; remoteInfo = Wortschatz;')
dependency = add('dependency', f'isa = PBXTargetDependency; target = {target}; targetProxy = {proxy};')
ui_target = add('uitarget', f'isa = PBXNativeTarget; buildConfigurationList = {ui_configlist}; buildPhases = ({ui_sources},); buildRules = (); dependencies = ({dependency},); name = WortschatzUITests; productName = WortschatzUITests; productReference = {ui_product}; productType = "com.apple.product-type.bundle.ui-testing";')
project = add('project', f'isa = PBXProject; attributes = {{ LastUpgradeCheck = 1600; }}; buildConfigurationList = {ident("projectconfigs")}; compatibilityVersion = "Xcode 14.0"; developmentRegion = en; hasScannedForEncodings = 0; knownRegions = (en,Base); mainGroup = {main}; productRefGroup = {products}; projectDirPath = ""; projectRoot = ""; targets = ({target},{ui_target},);')
out = ROOT/'Wortschatz.xcodeproj'/'project.pbxproj'
out.write_text('// !$*UTF8*$!\n{ archiveVersion = 1; classes = {}; objectVersion = 56; objects = {\n'+'\n'.join(objects)+f'\n}}; rootObject = {project}; }}\n')
print(out)

scheme = ROOT/'Wortschatz.xcodeproj'/'xcshareddata'/'xcschemes'/'Wortschatz.xcscheme'
scheme.parent.mkdir(parents=True, exist_ok=True)
def buildable(uid, name):
    return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{uid}" BuildableName="{name}" BlueprintName="{name.split(".")[0]}" ReferencedContainer="container:Wortschatz.xcodeproj"/>'
scheme.write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1600" version="1.3">
<BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{buildable(target, "Wortschatz.app")}</BuildActionEntry></BuildActionEntries></BuildAction>
<TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO">{buildable(ui_target, "WortschatzUITests.xctest")}</TestableReference></Testables></TestAction>
<LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{buildable(target, "Wortschatz.app")}</BuildableProductRunnable></LaunchAction>
<ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{buildable(target, "Wortschatz.app")}</BuildableProductRunnable></ProfileAction>
<AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>''')
