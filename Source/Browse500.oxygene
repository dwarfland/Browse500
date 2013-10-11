<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003" DefaultTargets="Build" ToolsVersion="4.0">
  <PropertyGroup>
    <RootNamespace>Browse500</RootNamespace>
    <ProjectGuid>56e52006-4538-414f-8afc-467e2bd69bd5</ProjectGuid>
    <OutputType>Executable</OutputType>
    <AssemblyName>Browse500</AssemblyName>
    <AllowGlobals>False</AllowGlobals>
    <AllowLegacyWith>False</AllowLegacyWith>
    <AllowLegacyOutParams>False</AllowLegacyOutParams>
    <AllowLegacyCreate>False</AllowLegacyCreate>
    <AllowUnsafeCode>False</AllowUnsafeCode>
    <Configuration Condition="'$(Configuration)' == ''">Release</Configuration>
    <SDK>iOS</SDK>
    <CreateAppBundle>True</CreateAppBundle>
    <InfoPListFile>.\Resources\Info.plist</InfoPListFile>
    <DeploymentTargetVersion>
    </DeploymentTargetVersion>
    <Name>Browse500</Name>
    <DefaultUses />
    <StartupClass />
    <BundleIdentifier>com.dwarfland.Browse500</BundleIdentifier>
    <EntitlementsFile>.\Resources\Browse500.entitlements</EntitlementsFile>
    <CreateHeaderFile>True</CreateHeaderFile>
    <BundleExtension />
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Debug' ">
    <Optimize>False</Optimize>
    <OutputPath>bin\Debug\</OutputPath>
    <DefineConstants>DEBUG;TRACE;</DefineConstants>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
    <ProvisioningProfile>6CBE66BA-D762-47CB-8D36-184FB3FA2E59</ProvisioningProfile>
    <ProvisioningProfileName>Browse500 Dev</ProvisioningProfileName>
    <CodesignCertificateName>iPhone Developer: marc hoffman (K2YTD84U6W)</CodesignCertificateName>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <Architecture>armv7;armv7s</Architecture>
    <SimulatorArchitectures>i386</SimulatorArchitectures>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Release' ">
    <Optimize>true</Optimize>
    <OutputPath>.\bin\Release</OutputPath>
    <GenerateDebugInfo>False</GenerateDebugInfo>
    <EnableAsserts>False</EnableAsserts>
    <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
    <CreateIPA>True</CreateIPA>
    <ProvisioningProfile>DCEF7E87-0282-4C01-B108-2A76E363A788</ProvisioningProfile>
    <ProvisioningProfileName>Browse500 App Store</ProvisioningProfileName>
    <CodesignCertificateName>iPhone Distribution: RemObjects Software</CodesignCertificateName>
  </PropertyGroup>
  <ItemGroup>
    <Reference Include="CoreGraphics.fx" />
    <Reference Include="Foundation.fx" />
    <Reference Include="libPXAPI.fx">
      <HintPath>..\libpxapi\iOS\libPXAPI.fx</HintPath>
    </Reference>
    <Reference Include="UIKit.fx" />
    <Reference Include="rtl.fx" />
  </ItemGroup>
  <ItemGroup>
    <Compile Include="AlbumCollectionViewCell.pas" />
    <Compile Include="AlbumViewController.pas" />
    <Compile Include="AppDelegate.pas" />
    <Compile Include="FavoritesAlbumViewController.pas" />
    <Compile Include="LoginViewController.pas" />
    <Compile Include="PhotoView.pas" />
    <Compile Include="PhotoViewController.pas" />
    <Compile Include="Preferences.pas" />
    <Compile Include="Program.pas" />
    <Compile Include="RootViewController.pas" />
    <Compile Include="ShowInSafariActivity.pas" />
    <AppResource Include="Resources\Categories.plist">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\02-star%402x.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\02-star.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\23-cloud%402x.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\23-cloud.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\24-person%402x.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\24-person.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\234-cloud%402x.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\234-cloud.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\298-circlex%402x.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\298-circlex.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\432-no%402x.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\432-no.png">
      <SubType>Content</SubType>
    </AppResource>
    <Content Include="Resources\Browse500.entitlements">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Resources\Info.plist" />
    <AppResource Include="Resources\App Icons\App-29.png" />
    <AppResource Include="Resources\App Icons\App-48.png" />
    <AppResource Include="Resources\App Icons\App-57.png" />
    <AppResource Include="Resources\App Icons\App-58.png" />
    <AppResource Include="Resources\App Icons\App-72.png" />
    <AppResource Include="Resources\App Icons\App-96.png" />
    <AppResource Include="Resources\App Icons\App-114.png" />
    <AppResource Include="Resources\App Icons\App-144.png" />
    <AppResource Include="Resources\OpenInSafari@2x~ipad.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\OpenInSafari~ipad.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\OpenInSafari@2x~iphone.png">
      <SubType>Content</SubType>
    </AppResource>
    <AppResource Include="Resources\OpenInSafari~iphone.png">
      <SubType>Content</SubType>
    </AppResource>
    <None Include="Resources\App Icons\App-512.png" />
    <None Include="Resources\App Icons\App-1024.png" />
    <AppResource Include="Resources\Launch Images\Default.png" />
    <AppResource Include="Resources\Launch Images\Default@2x.png" />
    <AppResource Include="Resources\Launch Images\Default-568h@2x.png" />
    <AppResource Include="Resources\Launch Images\Default-Portrait.png" />
    <AppResource Include="Resources\Launch Images\Default-Portrait@2x.png" />
    <AppResource Include="Resources\Launch Images\Default-Landscape.png" />
    <AppResource Include="Resources\Launch Images\Default-Landscape@2x.png" />
    <Xib Include="LoginViewController.xib">
      <DependentUpon>LoginViewController.pas</DependentUpon>
    </Xib>
    <Xib Include="PhotoViewController~iPad.xib" />
    <Xib Include="PhotoViewController~iPhone.xib" />
  </ItemGroup>
  <ItemGroup />
  <ItemGroup>
    <Folder Include="Properties\" />
    <Folder Include="Resources\" />
    <Folder Include="Resources\App Icons\" />
    <Folder Include="Resources\Launch Images\" />
  </ItemGroup>
  <ItemGroup />
  <Import Project="$(MSBuildExtensionsPath)\RemObjects Software\Oxygene\RemObjects.Oxygene.Nougat.targets" />
  <PropertyGroup>
    <PreBuildEvent />
  </PropertyGroup>
</Project>