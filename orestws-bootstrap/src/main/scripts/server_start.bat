@ECHO OFF

REM ==================================================
REM ORESTWS start script for Windows
REM Note: Assuming Windows is for development,
REM       JPDA debugging is on
REM ==================================================

REM ==================================================
REM Uncomment only one of the two lines below
REM ==================================================
REM SET ENV_NAME=production
SET ENV_NAME=development

SET JPDA_PORT=8888

SET ORESTWS_HOME=%~dp0
SET ORESTWS_HOME=%ORESTWS_HOME%\..

IF [%1]==[] GOTO default
IF [%1]==[/?] GOTO help
IF [%1]==[-?] GOTO help
IF [%1]==[/h] GOTO help
IF [%1]==[/H] GOTO help
IF [%1]==[-h] GOTO help
IF [%1]==[-H] GOTO help
SET JAVA_MEM_MB=%1
GOTO exec

:help
ECHO Usage:
ECHO     server_start.bat [memory in Mb]
ECHO     server_start.bat /?
GOTO end

:default
SET JAVA_MEM_MB=64

:exec
REM -XX:-UseGCOverheadLimit
SET OPTS_JVM=-server -Xms%JAVA_MEM_MB%m -Xmx%JAVA_MEM_MB%m -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true -XX:+UseParNewGC -XX:+UseConcMarkSweepGC
SET OPTS_GC_LOG=-XX:PrintFLSStatistics=1 -XX:PrintCMSStatistics=1 -XX:+PrintTenuringDistribution -XX:+PrintGCDetails -XX:+PrintGCDateStamps -verbose:gc -Xloggc:%ORESTWS_HOME%\logs\garbage.log
SET OPTS_ORESTWS=-Dorestws.home=%ORESTWS_HOME% -Dorestws.osgi.properties=%ORESTWS_HOME%\bin\osgi-felix.properties
SET OPTS_CLASSPATH=-classpath "%ORESTWS_HOME%\lib;%ORESTWS_HOME%\lib\*"

java -Dlog4j.configuration=log4j-%ENV_NAME%.xml -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=%JPDA_PORT% %OPTS_JVM% %OPTS_GC_LOG% %OPTS_ORESTWS% %OPTS_CLASSPATH% com.github.ddth.orestws.bootstrap.StandaloneBootstrap

:end
