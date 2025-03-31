@@echo off

REM Choose the option flag
REM https://wiki.st.com/stm32mpu/wiki/STM32_header_for_binary_files
REM 
REM 0x80000000: Header padding enabled
REM OPTION_FLAG=0x80000000
REM 0x80000001: Header padding enabled, authentication enabled
REM SET OPTION_FLAG=0x80000001
REM 0x80000003: Header padding enabled, authentication enabled, decryption enabled
REM SET OPTION_FLAG=0x80000003
REM Initialize option flag and output file name

SET PROJECT_NAME=
SET BASE_OPTION_FLAG=0x8000000
SET FILE_SUFFIX=
SET /A INDEX_FLAG = 0

REM The followings are variables needs manual modification
SET version=0x00000001
SET pwd=rot1

@REM SET pwd1=../../Keys/publicKey00.pem
@REM SET pwd2=../../Keys/publicKey01.pem
@REM SET pwd3=../../Keys/publicKey02.pem
@REM SET pwd4=../../Keys/publicKey03.pem
@REM SET pwd5=../../Keys/publicKey04.pem
@REM SET pwd6=../../Keys/publicKey05.pem
@REM SET pwd7=../../Keys/publicKey06.pem
@REM SET pwd8=../../Keys/publicKey07.pem

@REM SET prvk=../../Keys/privateKey00.pem

@REM SET derivation_value=0x7C098AF2
@REM SET enck=../../Keys/OEM_SECRET.bin

SET pwd1=
SET pwd2=
SET pwd3=
SET pwd4=
SET pwd5=
SET pwd6=
SET pwd7=
SET pwd8=

SET prvk=

SET derivation_value=
SET enck=

IF "%~1"=="" (
    REM no option to sign the image without authentication and generate image_signed-without-authentication.bin
    SET /A INDEX_FLAG^|=0
    SET /A CASE^|=0
    SET FILE_SUFFIX=%FILE_SUFFIX%_signed-without-authentication
    GOTO PROCESS
) ELSE IF "%~1"=="help" (
    REM option "help" to Show help message
    echo Usage: n6sign.bat [option]
    echo.
    echo Options:
    echo   -enc     - Encrypt the image and generate image_encrypted.bin
    echo   -auth    - Sign the image with authentication and generate image_authenticated.bin
    echo   help     - Display this help message
    echo.
    echo If no option is provided, the script will sign the image without authentication and generate image_signed-without-authentication.bin.
    EXIT /B 0
)

REM Parse arguments
:PARSE_ARGS
IF "%~1"=="" GOTO :PROCESS
IF "%~1"=="-enc" (
    REM option "-enc" to encrypt the image and generate image_encrypted.bin
    SET /A INDEX_FLAG^|=2
    @REM SET /A CASE+=2
    SET FILE_SUFFIX=%FILE_SUFFIX%_encrypted
    @REM SET /A CASE=CASE+2
)
IF "%~1"=="-auth" (
    REM option "-auth" to sign the image with authentication and generate image_authenticated.bin
    SET /A INDEX_FLAG^|=1
    @REM SET /A CASE+=1
    SET FILE_SUFFIX=%FILE_SUFFIX%_authentication
    @REM SET /A CASE=CASE+1
)
SHIFT
GOTO :PARSE_ARGS

:PROCESS
REM Find the .elf file in the current directory and set its name as PROJECT_NAME
IF EXIST *.elf (
    @REM GOTO :FOUND_ELF
    FOR %%f IN (*.elf) DO (
        SET PROJECT_NAME=%%~nf
        GOTO :FOUND_ELF
    )
) ELSE (
    ECHO No .elf file found in the current directory.
    ECHO Please build the project by IDE first!
    EXIT /B 1
)

:FOUND_ELF
IF EXIST %PROJECT_NAME%.bin (
    GOTO :FOUND_BIN
) ELSE (
    @REM :BIN_NOT_FOUND
    ECHO No .bin file found in the current directory.
    ECHO Please build the project by IDE first!
    EXIT /B 1
)

:FOUND_BIN
SET /A CASE=10+INDEX_FLAG
SET OPTION_FLAG=%BASE_OPTION_FLAG%%INDEX_FLAG%
SET OUTPUT_FILE=%PROJECT_NAME%%FILE_SUFFIX%

echo CASE=%CASE%
echo FILE_SUFFIX=%FILE_SUFFIX%
echo PROJECT_NAME=%PROJECT_NAME%
echo OPTION_FLAG=%OPTION_FLAG%
echo OUTPUT_FILE=%OUTPUT_FILE%

REM sign without authentication
IF "%CASE%"=="10" (
    @REM ECHO CASE10
    STM32_SigningTool_CLI.exe -bin %PROJECT_NAME%.bin -nk -of %OPTION_FLAG% -t fsbl -o %OUTPUT_FILE%.bin -hv 2.3 -dump %OUTPUT_FILE%.bin
    GOTO :EOF
)

REM sign with authentication 
IF "%CASE%"=="11" (
    @REM ECHO CASE11
    IF "%pwd1%"=="" IF "%pwd2%"=="" IF "%pwd3%"=="" IF "%pwd4%"=="" IF "%pwd5%"=="" IF "%pwd6%"=="" IF "%pwd7%"=="" IF "%pwd8%"=="" IF "%prvk%"=="" (
        ECHO .
        ECHO Error!!
        ECHO Please set the file path for public keys!!
        ECHO .
        @REM EXIT /B 1
    ) else (
        ECHO .
        ECHO Signing the image with authentication...
        ECHO pwd1 = %pwd1% 
        ECHO pwd2 = %pwd2%
        ECHO pwd3 = %pwd3%
        ECHO pwd4 = %pwd4%
        ECHO pwd5 = %pwd5%
        ECHO pwd6 = %pwd6%
        ECHO pwd7 = %pwd7%
        ECHO pwd8 = %pwd8%
        ECHO prvk = %prvk%
        ECHO .
        @REM STM32_SigningTool_CLI.exe -bin H573-DK_Makefile_CMake.bin -pubk ../../Keys/publicKey00.pem ../../Keys/publicKey01.pem ../../Keys/publicKey02.pem ../../Keys/publicKey03.pem ../../Keys/publicKey04.pem ../../Keys/publicKey05.pem ../../Keys/publicKey06.pem../../Keys/publicKey07.pem -prvk ../../Keys/privateKey00.pem -pwd rot1 -t fsbl -iv 0x00000001 -la 0x34180000 -of 0x80000001 -hv 2.3 -o test.bin -dump test.bin
        STM32_SigningTool_CLI.exe -bin %PROJECT_NAME%.bin -pubk %pwd1% %pwd2% %pwd3% %pwd4% %pwd5% %pwd6% %pwd7% %pwd8% -prvk %prvk% -pwd %pwd% -t fsbl -iv %version% -la 0x34180000 -of 0x80000001 -hv 2.3 -o %OUTPUT_FILE%.bin -dump %OUTPUT_FILE%.bin
    )
)

REM encrypt the image and sign the image without authentication
IF "%CASE%"=="12" (
    @REM ECHO CASE12
    IF "%pwd1%"=="" IF "%pwd2%"=="" IF "%pwd3%"=="" IF "%pwd4%"=="" IF "%pwd5%"=="" IF "%pwd6%"=="" IF "%pwd7%"=="" IF "%pwd8%"=="" IF "%prvk%"=="" IF "%derivation_value%"=="" IF "%enck%"=="" (
    ) else (

    )
)

REM encrypt and sign the image with authentication
IF "%CASE%"=="13" (
    @REM ECHO CASE13
)
