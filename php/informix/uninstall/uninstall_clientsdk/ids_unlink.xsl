<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Licensed Materials - Property of IBM

	"Restricted Materials of IBM"

	IBM Informix Dynamic Server
	Copyright IBM Corporation 2010, 2015
	-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:idsext="xalan://com.ibm.informix.install.IDSXSLExtensions">
	<xsl:param name="edition" select="'Developer'"></xsl:param>
	<xsl:param name="platform" select="'linux86_64'"></xsl:param>
	<xsl:param name="product" select="'IBM Informix Client-SDK'"></xsl:param>
	<xsl:param name="component" select="translate('IFMX_FEATURE_SELECT',',',' ')"></xsl:param>
	<xsl:param name="aao_user" select="'IFMX_AAOUSER'"></xsl:param>
	<xsl:param name="aao_grp" select="'IFMX_AAOGROUP'"></xsl:param>
	<xsl:param name="dbso_user" select="'IFMX_DBSOUSER'"></xsl:param>
	<xsl:param name="dbso_grp" select="'IFMX_DBSOGROUP'"></xsl:param>
	<xsl:param name="unix_user_installtype_select" select="'IFMX_UNIX_INSTALLTYPE_SELECT'"></xsl:param>
	<xsl:param name="action_list" select="'IFMX_POSTACTIONLIST'"></xsl:param>
	<xsl:output method="text" omit-xml-declaration="yes" />

	<!-- Set machine normalized platform -->
	<xsl:variable name="machinetype">
		<xsl:choose>
			<xsl:when test="$platform = 'macosx'">
				<xsl:text>macosx32</xsl:text>
			</xsl:when>
			<xsl:when test="$platform = 'linux'">
				<xsl:text>linux32</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$platform" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- Set machinegroup to either all-unix32 all-unix64 or all-win -->
	<xsl:variable name="machinegroup">
		<xsl:choose>
			<xsl:when test="$machinetype = 'intel.solaris' or $machinetype = 'solaris' or $machinetype = 'hp11' or $machinetype = 'hpia32' or $machinetype = 'ibmrs6000' or $machinetype = 'macosx32' or $machinetype = 'zlinux32' or $machinetype = 'linux32' or $machinetype = 'linuxARM32'">
				<xsl:value-of select="'all-unix32'" />
			</xsl:when>
			<xsl:when test="$machinetype = 'linux86_64' or $machinetype = 'solx86_64' or $machinetype = 'sol64' or $machinetype = 'hp64' or $machinetype = 'hpia64' or $machinetype = 'ibm64' or $machinetype = 'macosx64' or $machinetype = 'linuxppc64' or $machinetype = 'linuxppc64le' or $machinetype = 'linuxia64' or $machinetype = 'zlinux64'">
				<xsl:value-of select="'all-unix64'" />
			</xsl:when>
			<xsl:when test="$machinetype = 'nt_intel' or $machinetype = 'win64_amd'">
				<xsl:value-of select="'all-win'" />
			</xsl:when>
		</xsl:choose>
	</xsl:variable>

	<!-- component_name to the list of components actually installed. -->
	<xsl:variable name="component_name_int1" select="idsext:ListReplace($component,'GLS SDK CON','GLS-CORE SDK-CORE CON-CORE')" />
	<xsl:variable name="component_name_manifest" select="idsext:ListAppend($component_name_int1, 'IDS-SVR', 'DBA-DBA')" />
	<xsl:variable name="component_name_int2" select="idsext:ListAppend($component_name_manifest, 'CON-CORE', 'CON-ONLY')" />
	<xsl:variable name="component_name_int3" select="idsext:ListAppend($component_name_int2,
				'SDK-CORE SDK-OLE SDK-OLE-RT SDK-CPP SDK-ESQL SDK-ESQL-ACM SDK-NET SDK-LMI SDK-ODBC', 
				'CON-CORE CON-OLE CON-OLE-RT CON-CPP CON-ESQL CON-ESQL-ACM CON-NET CON-LMI CON-ODBC')" />
	<xsl:variable name="component_name_int4" select="idsext:ListAppend($component_name_int3, 'CON-NET', 'CON-NET11')" />
	<xsl:variable name="component_name" select="idsext:ListAppend($component_name_int4, 'IDS CON-CORE', 'GSKIT GSKIT')" />

	<!-- List of products included by a type of installer -->
	<xsl:variable name="prodgroup">
		<xsl:choose>
			<xsl:when test="$product = 'IBM Informix Bundle Project'">
				<xsl:text>IBM Informix Dynamic Server IBM Informix Client-SDK IBM Informix Connect Dbaccess Informix Global Language Supplement IBM Informix Dynamic Server Messages IBM GSKIT IBM JRE IBM Informix JDBC</xsl:text>
			</xsl:when>
			<xsl:when test="$product = 'IBM Informix Dynamic Server'">
				<xsl:text>Dbaccess Informix Global Language Supplement IBM Informix Dynamic Server Messages IBM GSKIT IBM JRE</xsl:text>
			</xsl:when>
			<xsl:when test="$product = 'IBM Informix Client-SDK'">
				<xsl:text>Dbaccess Informix Global Language Supplement IBM Informix Connect IBM GSKIT</xsl:text>
			</xsl:when>
			<xsl:when test="$product = 'IBM Informix Connect'">
				<xsl:text>Informix Global Language Supplement IBM GSKIT</xsl:text>
			</xsl:when>
			<xsl:when test="$product = 'IBM Informix GLS'">
				<xsl:text>Informix Global Language Supplement</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>

	<xsl:template name="umask">
		<xsl:param name="ap" />
		<xsl:variable name="len" select="string-length($ap)" />
		<xsl:variable name="char" select="substring($ap, 1, 1)" />
		<xsl:variable name="rest" select="substring($ap, 2, $len - 1)" />
		<xsl:choose>
			<xsl:when test="$len &gt; 3">
				<xsl:call-template name="umask">
					<xsl:with-param name="ap" select="$rest" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$len = 3">
				<xsl:value-of select="$char" />
				<xsl:call-template name="umask">
					<xsl:with-param name="ap" select="$rest" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$len &gt; 0">
				<xsl:choose>
					<xsl:when test="$char = '7' or $char = '5'">
						<xsl:text>5</xsl:text>
					</xsl:when>
					<xsl:when test="$char = '6' or $char = '4'">
						<xsl:text>4</xsl:text>
					</xsl:when>
					<xsl:when test="$char = '3' or $char = '1'">
						<xsl:text>1</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>0</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="umask">
					<xsl:with-param name="ap" select="$rest" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- Replace a token in a value -->
	<xsl:template name="substitute-token">
		<xsl:param name="input" />
		<xsl:param name="token" />
		<xsl:param name="replace" />
		<xsl:choose>
			<xsl:when test="$token and contains($input, $token)">
				<xsl:value-of select="substring-before($input,$token)" />
				<xsl:value-of select="$replace" />
				<xsl:call-template name="substitute-token">
					<xsl:with-param name="input" select="substring-after($input,$token)" />
					<xsl:with-param name="token" select="$token" />
					<xsl:with-param name="replace" select="$replace" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$input" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="/Bundle">
		<xsl:apply-templates select="Package" />
	</xsl:template>
	<xsl:template match="Package" />
	<xsl:template match="Package[contains(PackageName, $product) or contains($prodgroup, PackageName)]">
		<xsl:choose>
			<xsl:when test="contains($action_list, 'MANIFEST')">
				<xsl:apply-templates select="Feature" mode="MANIFEST" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="Feature" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="Feature" />
	<xsl:template match="Feature" mode="MANIFEST" />
	<xsl:template match="Feature[idsext:ListIntersect($component_name_manifest, FeatureName)]
								[idsext:ListIntersect(FeatureEdition, $edition) or FeatureEdition = 'All']
								[idsext:ListIntersect(FeatureValidPlatforms, $machinetype) or idsext:ListIntersect(FeatureValidPlatforms, $machinegroup)
								or FeatureValidPlatforms = 'all']" mode="MANIFEST">
		<xsl:apply-templates select="FeatureMember" mode="MANIFEST" />
	</xsl:template>
	<xsl:template match="Feature[idsext:ListIntersect($component_name, FeatureName)]
								[idsext:ListIntersect(FeatureEdition, $edition) or FeatureEdition = 'All']
								[idsext:ListIntersect(FeatureValidPlatforms, $machinetype) or idsext:ListIntersect(FeatureValidPlatforms, $machinegroup)
								or FeatureValidPlatforms = 'all']">
		<xsl:apply-templates select="FeatureMember" />
	</xsl:template>
	<xsl:template match="FeatureMember" />
	<xsl:template match="FeatureMember[ ( not(ValidEditions) or idsext:ListIntersect(ValidEditions, $edition)
									or ValidEditions = 'All' or not(ValidEditions) ) 
									and
									( ValidPlatforms = 'all' or idsext:ListIntersect(ValidPlatforms, $machinetype) 
									   or idsext:ListIntersect(ValidPlatforms, $machinegroup) )
									 ]">
		<xsl:choose>
			<xsl:when test="contains($action_list, 'CHKDIR')">
				<xsl:apply-templates select="." mode="CHKDIR" />
			</xsl:when>
			<xsl:when test="contains($action_list, 'GETTARGETS')">
				<xsl:apply-templates select="." mode="GETTARGETS" />
			</xsl:when>
			<xsl:when test="contains($action_list, 'FILESNOOVHD')">
				<xsl:apply-templates select="." mode="FILESNOOVHD" />
			</xsl:when>
			<xsl:when test="contains($action_list, 'RPMTARGETS')">
				<xsl:apply-templates select="." mode="RPMTARGETS" />
			</xsl:when>
			<xsl:when test="contains($action_list, 'DIRPERMS')">
				<xsl:apply-templates select="." mode="DIRPERMS" />
			</xsl:when>
			<xsl:when test="contains($action_list, 'REMOVELINKS') or contains($action_list, 'UNINSTALL')">
				<xsl:if test="contains($action_list, 'REMOVELINKS')">
					<xsl:apply-templates select="." mode="REMOVELINKS" />
				</xsl:if>
				<xsl:if test="contains($action_list, 'UNINSTALL')">
					<xsl:apply-templates select="." mode="UNINSTALL" />
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="contains($action_list, 'PREINSTALL')">
					<xsl:apply-templates select="." mode="PREINSTALL" />
				</xsl:if>
				<xsl:if test="contains($action_list, 'POSTINSTALL')">
					<xsl:apply-templates select="." mode="POSTINSTALL" />
				</xsl:if>
				<xsl:if test="contains($action_list, 'MAKELINKS')">
					<xsl:apply-templates select="." mode="MAKELINKS" />
				</xsl:if>
				<xsl:if test="contains($action_list, 'BRAND')">
					<xsl:apply-templates select="." mode="BRAND" />
				</xsl:if>
				<xsl:if test="contains($action_list, 'OWNGROUP')">
					<xsl:apply-templates select="." mode="OWNGROUP" />
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="CHKDIR" />
	<xsl:template match="FeatureMember[Type = 'Directory']" mode="CHKDIR">
		<xsl:value-of select="@id" />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="GETTARGETS" />
	<xsl:template match="FeatureMember[Type != 'Directory']" mode="GETTARGETS">
		<xsl:apply-templates select="." mode="targetname" />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
        
	<xsl:template match="FeatureMember" mode="FILESNOOVHD" />
	<xsl:template match="FeatureMember[((Type != 'Directory') and (Type != 'InstallOverhead') and (Type != 'Link') and (Type != 'SharedLibLink') )]" mode="FILESNOOVHD">
		<xsl:apply-templates select="." mode="targetname" />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="BRAND" />
	<xsl:template match="FeatureMember[((BrandStamp = 'true') and (not(contains(Type, 'Link'))))]" mode="BRAND">
		<xsl:choose>
			<xsl:when test="$machinegroup = 'all-win'">
				<xsl:text>etc\brand -n -s AAA#B000000 NOZDIP </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>etc/brand -n -s AAA#B000000 NOZDIP </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="." mode="targetname" />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="REMOVELINKS" />
	<xsl:template match="FeatureMember[contains(Type, 'Link')]" mode="REMOVELINKS">
		<xsl:choose>
			<xsl:when test="$machinegroup = 'all-win'">
				<xsl:text>IF EXIST </xsl:text>
				<xsl:apply-templates select="." mode="targetname" />
				<xsl:text> del /f </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="Type = 'SoftLink'">
						<xsl:text>[ -h "</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>[ -f "</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates select="." mode="targetname" />
				<xsl:text>" ] &#x26;&#x26; rm -f </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="." mode="targetname" />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="UNINSTALL" />
	<xsl:template match="FeatureMember[UninstallAction]" mode="UNINSTALL">
		<xsl:variable name="replacementString">
			<xsl:apply-templates select="." mode="targetname" />
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="UninstallAction[idsext:ListIntersect(@platform, $machinetype)]">
				<xsl:call-template name="substitute-token">
					<xsl:with-param name="input" select="UninstallAction[idsext:ListIntersect(@platform, $machinetype)]" />
					<xsl:with-param name="token" select="'@id'" />
					<xsl:with-param name="replace" select="$replacementString" />
				</xsl:call-template>
				<xsl:text>&#xa;</xsl:text>
			</xsl:when>
			<xsl:when test="UninstallAction[idsext:ListIntersect(@platform, $machinegroup)]">
				<xsl:call-template name="substitute-token">
					<xsl:with-param name="input" select="UninstallAction[idsext:ListIntersect(@platform, $machinegroup)]" />
					<xsl:with-param name="token" select="'@id'" />
					<xsl:with-param name="replace" select="$replacementString" />
				</xsl:call-template>
				<xsl:text>&#xa;</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="PREINSTALL" />
	<xsl:template match="FeatureMember[PreInstallAction]" mode="PREINSTALL">
		<xsl:variable name="replacementString">
			<xsl:apply-templates select="." mode="targetname" />
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="PreInstallAction[idsext:ListIntersect(@platform, $machinetype)]">
				<xsl:call-template name="substitute-token">
					<xsl:with-param name="input" select="PreInstallAction[idsext:ListIntersect(@platform, $machinetype)]" />
					<xsl:with-param name="token" select="'@id'" />
					<xsl:with-param name="replace" select="$replacementString" />
				</xsl:call-template>
				<xsl:text>&#xa;</xsl:text>
			</xsl:when>
			<xsl:when test="PreInstallAction[idsext:ListIntersect(@platform, $machinegroup)]">
				<xsl:call-template name="substitute-token">
					<xsl:with-param name="input" select="PreInstallAction[idsext:ListIntersect(@platform, $machinegroup)]" />
					<xsl:with-param name="token" select="'@id'" />
					<xsl:with-param name="replace" select="$replacementString" />
				</xsl:call-template>
				<xsl:text>&#xa;</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="POSTINSTALL" />
	<xsl:template match="FeatureMember[PostInstallAction]" mode="POSTINSTALL">
		<xsl:variable name="replacementString">
			<xsl:apply-templates select="." mode="targetname" />
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="PostInstallAction[idsext:ListIntersect(@platform, $machinetype)]">
				<xsl:call-template name="substitute-token">
					<xsl:with-param name="input" select="PostInstallAction[idsext:ListIntersect(@platform, $machinetype)]" />
					<xsl:with-param name="token" select="'@id'" />
					<xsl:with-param name="replace" select="$replacementString" />
				</xsl:call-template>
				<xsl:text>&#xa;</xsl:text>
			</xsl:when>
			<xsl:when test="PostInstallAction[idsext:ListIntersect(@platform, $machinegroup)]">
				<xsl:call-template name="substitute-token">
					<xsl:with-param name="input" select="PostInstallAction[idsext:ListIntersect(@platform, $machinegroup)]" />
					<xsl:with-param name="token" select="'@id'" />
					<xsl:with-param name="replace" select="$replacementString" />
				</xsl:call-template>
				<xsl:text>&#xa;</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="RPMTARGETS"/>
	<xsl:template match="FeatureMember[not(contains(Type, 'Directory')  or contains(Type, 'InstallOverhead'))]" mode="RPMTARGETS">
		<xsl:text>%attr</xsl:text>
		<xsl:text>&#x28;</xsl:text>
		<xsl:if test="not(contains($unix_user_installtype_select, 'PRIVATE'))">
			<xsl:value-of select="AccessPermissions" />
			<xsl:text>&#x2C;</xsl:text>
			<xsl:apply-templates select="." mode="owner" />
			<xsl:text>&#x2C;</xsl:text>
			<xsl:apply-templates select="." mode="group" />
		</xsl:if>
		<xsl:if test="contains($unix_user_installtype_select, 'PRIVATE')">
			<xsl:call-template name="umask">
				<xsl:with-param name="ap" select="AccessPermissions" />
			</xsl:call-template>
			<xsl:text>&#x2C;</xsl:text>
			<xsl:text>&#x2D;</xsl:text>
			<xsl:text>&#x2C;</xsl:text>
			<xsl:text>&#x2D;</xsl:text>
		</xsl:if>
		<xsl:text>&#x29;</xsl:text>
		<xsl:text> </xsl:text>
		<xsl:text>%{_prefix}/</xsl:text>
		<xsl:apply-templates select="." mode="targetname" />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
		
	<xsl:template match="FeatureMember" mode="PERMS" />
	<xsl:template match="FeatureMember[not(contains(Type, 'Link'))]" mode="PERMS">
		<xsl:if test="$machinegroup  != 'all-win'">
			<xsl:text>chmod </xsl:text>
			<xsl:if test="not(contains($unix_user_installtype_select,'PRIVATE'))">
				<xsl:value-of select="AccessPermissions" />
			</xsl:if>
			<xsl:if test="contains($unix_user_installtype_select, 'PRIVATE')">
				<xsl:call-template name="umask">
					<xsl:with-param name="ap" select="AccessPermissions" />
				</xsl:call-template>
			</xsl:if>
			<xsl:text> </xsl:text>
			<xsl:apply-templates select="." mode="targetname" />
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="DIRPERMS" />
	<xsl:template match="FeatureMember[contains(Type, 'Directory')]" mode="DIRPERMS">
		<xsl:if test="$machinegroup != 'all-win'">
			<xsl:text>chown </xsl:text>
			<xsl:apply-templates select="." mode="owner" />
			<xsl:text>&#x3A;</xsl:text>
			<xsl:apply-templates select="." mode="group" />
			<xsl:text> </xsl:text>
			<xsl:apply-templates select="." mode="targetname" />
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="OWNGROUP" />
	<xsl:template match="FeatureMember[not(contains(Type, 'Link')) and (Type != 'InstallOverhead')]" mode="OWNGROUP">
		<xsl:if test="$machinegroup  != 'all-win'">
			<xsl:if test="not(contains($unix_user_installtype_select,'PRIVATE'))">
				<xsl:text>chown </xsl:text>
				<xsl:apply-templates select="." mode="owner" />
				<xsl:text>&#x3A;</xsl:text>
				<xsl:apply-templates select="." mode="group" />
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="." mode="targetname" />
				<xsl:text>&#xa;</xsl:text>
			</xsl:if>
			<xsl:apply-templates select="." mode="PERMS" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="MAKELINKS" />
	<xsl:template match="FeatureMember[contains(Type, 'Link')]" mode="MAKELINKS">
		<xsl:choose>
			<xsl:when test="$machinegroup = 'all-win'">
				<xsl:text>IF NOT EXIST </xsl:text>
				<xsl:apply-templates select="." mode="targetname" />
				<xsl:text> copy </xsl:text>
			</xsl:when>
			<xsl:when test="Type = 'SoftLink'">
				<xsl:text>ln -s </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>[ ! -f "</xsl:text>
				<xsl:apply-templates select="." mode="targetname" />
				<xsl:text>" ] &#x26;&#x26; ln </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="." mode="sourcename" />
		<xsl:text>&#x20;</xsl:text>
		<xsl:apply-templates select="." mode="targetname" />
		<xsl:text>&#xA;</xsl:text>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="MANIFEST" />
	<xsl:template match="FeatureMember[((idsext:ListIntersect(ValidEditions, $edition)
									or ValidEditions = 'All' or not(ValidEditions)) and
									(idsext:ListIntersect(ValidPlatforms, $machinetype) or idsext:ListIntersect(ValidPlatforms, $machinegroup)
									or ValidPlatforms = 'all') and
									(not(idsext:ListIntersect(Type, 'Directory Link SharedLibLink SoftLink SharedLibSoftLink InstallOverhead'))))]" mode="MANIFEST">
		<xsl:value-of select="'F,$BUILD_SOURCE$/'" />
		<xsl:apply-templates select="." mode='buildsource' />
		<xsl:value-of select="',./'" />
		<xsl:apply-templates select="." mode='buildtarget' />
		<xsl:value-of select="','" />
		<xsl:value-of select="AccessPermissions" />
		<xsl:text>&#xA;</xsl:text>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="owner">
		<xsl:choose>
			<xsl:when test="Owner = 'aaouser'">
				<xsl:value-of select="$aao_user" />
			</xsl:when>
			<xsl:when test="Owner = 'dbssouser'">
				<xsl:value-of select="$dbso_user" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="Owner" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="group">
		<xsl:choose>
			<xsl:when test="Group = 'aaogroup'">
				<xsl:value-of select="$aao_grp" />
			</xsl:when>
			<xsl:when test="Group = 'dbssogroup'">
				<xsl:value-of select="$dbso_grp" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="Group" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="FeatureMember" mode="targetname">
		<xsl:choose>
			<xsl:when test="SpecificTargetName[idsext:ListIntersect(@platform, $machinetype)]">
				<xsl:value-of select="SpecificTargetName[idsext:ListIntersect(@platform, $machinetype)]" />
			</xsl:when>
			<xsl:when test="SpecificTargetName[idsext:ListIntersect(@platform, $machinegroup)]">
				<xsl:value-of select="SpecificTargetName[idsext:ListIntersect(@platform, $machinegroup)]" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$machinegroup = 'all-win'">
						<xsl:value-of select="translate(@id, '/', '\')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@id" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates select='.' mode="processextension" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="FeatureMember" mode="processextension">
		<xsl:choose>
			<xsl:when test="Type = 'CommandScript' and $machinegroup = 'all-win'">
				<xsl:text>.bat</xsl:text>
			</xsl:when>
			<xsl:when test="Type = 'CommandScript'">
				<xsl:text>.sh</xsl:text>
			</xsl:when>
			<xsl:when test="Type = 'Executable' and $machinegroup = 'all-win'">
				<xsl:text>.exe</xsl:text>
			</xsl:when>
			<xsl:when test="Type = 'StaticLib' and $machinegroup = 'all-win'">
				<xsl:text>.lib</xsl:text>
			</xsl:when>
			<xsl:when test="Type = 'StaticLib'">
				<xsl:text>.a</xsl:text>
			</xsl:when>
			<xsl:when test="(Type = 'SharedLib' or Type = 'SharedLibLink') and $machinegroup = 'all-win'">
				<xsl:text>.dll</xsl:text>
			</xsl:when>
			<xsl:when test="(Type = 'SharedLib' or Type = 'SharedLibLink') and contains($machinetype, 'macosx')">
				<xsl:text>.dylib</xsl:text>
			</xsl:when>
			<xsl:when test="(Type = 'SharedLib' or Type = 'SharedLibLink') and ($machinetype = 'hp11' or $machinetype = 'hp64')">
				<xsl:text>.sl</xsl:text>
			</xsl:when>
			<xsl:when test="Type = 'SharedLib' or Type = 'SharedLibLink'">
				<xsl:text>.so</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="FeatureMember[not(LinkSource)]" mode="sourcename" />
	<xsl:template match="FeatureMember" mode="sourcename">
		<xsl:choose>
			<xsl:when test="$machinegroup = 'all-win'">
				<xsl:value-of select="translate(LinkSource, '/', '\')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="LinkSource" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="Type = 'SharedLibLink' and $machinegroup = 'all-win'">
				<xsl:text>.dll</xsl:text>
			</xsl:when>
			<xsl:when test="Type = 'SharedLibLink' and contains($machinetype, 'macosx')">
				<xsl:text>.dylib</xsl:text>
			</xsl:when>
			<xsl:when test="Type = 'SharedLibLink' and ($machinetype = 'hp11' or $machinetype = 'hp64')">
				<xsl:text>.sl</xsl:text>
			</xsl:when>
			<xsl:when test="Type = 'SharedLibLink'">
				<xsl:text>.so</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="FeatureMember" mode="buildtarget">
		<xsl:choose>
			<xsl:when test="SpecificTargetName[idsext:ListIntersect(@platform, $machinetype)]">
				<xsl:value-of select="SpecificTargetName[idsext:ListIntersect(@platform, $machinetype)]" />
			</xsl:when>
			<xsl:when test="SpecificTargetName[idsext:ListIntersect(@platform, $machinegroup)]">
				<xsl:value-of select="SpecificTargetName[idsext:ListIntersect(@platform, $machinegroup)]" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@id" />
				<xsl:apply-templates select='.' mode="processextension" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="FeatureMember" mode="buildsource">
		<xsl:choose>
			<xsl:when test="SourceLocation[idsext:ListIntersect(@platform, $machinetype)]">
				<xsl:value-of select="SourceLocation[idsext:ListIntersect(@platform, $machinetype)]" />
			</xsl:when>
			<xsl:when test="SourceLocation[idsext:ListIntersect(@platform, $machinegroup)]">
				<xsl:value-of select="SourceLocation[idsext:ListIntersect(@platform, $machinegroup)]" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@id" />
				<xsl:apply-templates select='.' mode="processextension" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
