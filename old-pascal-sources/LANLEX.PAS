{*********************************************}
{*                                           *}
{*  Lation Lexicon RUS/LAT words Data unit   *}
{*  Nikol Bochkaryev 1993  B_N_V my Corp..   *}
{*                                           *}
{*********************************************}

unit LanLex;

 interface
 var Engl : boolean;
 var L : array[0..120] of String[80];

 procedure InitRusLat;

 implementation

 procedure InitRusLat;
 begin
     Case Engl of
      True :
	begin
 {********************************************}
 {*             MENULEX.PAS                  *}
 {********************************************}

	  L[0] := ' Main Menu ';
	  L[1] := '  Information';
	  L[2] := ' All information about this program';
	  L[3] := '   Begin test';
	  L[4] := ' Start Main Test this program';
	  L[5] := ' Easy ';
	  L[6] := ' Easy  level of difficalty have one level of test (7 words)';
	  L[7] := ' Medium ';
	  L[8] := ' Medium level of difficalty have two levels of test (14 words)';
	  L[9] := ' Complicated ';
	  L[10] := ' Hard  level of difficalty have three levels of test (21 words)';
	  L[11] := '   Environment';
	  L[12] := ' Set options of environment this program';
	  L[13] := ' Environment ';
	  L[14] := ' Help             ';
	  L[15] := ' Help on RUS or LAT ?';
	  L[16] := ' Loading File...  ';
	  L[17] := ' Statistics Your Test ';
	  L[18] := ' What Lation Lexicon File loading for You test';
	  L[19] := '      Exit';
	  L[20] := ' Finish this program, exit to DOS';
	  L[21] := ' Warning ';
	  L[22] := ' Current Vocabulary file ';
	  L[23] := 'Get Vocabulary file';
	  L[24] := ' Directory of ';
	  L[25] := '  All files    ';
	  L[26] := ' Select mask of show files or Esc to quit in Main Menu';
	  L[27] := 'Not enough memory for this operation';
	  L[28] := 'Critical Error';
	  L[29] := 'Drive not ready';
	  L[30] := 'Data error reading';
	  L[31] := 'Sector not found';
	  L[32] := 'Disk seek error';
	  L[33] := 'Device write fault';
	  L[34] := 'Hardware failure';
	  L[35] := 'Saving . . .';
 {********************************************}
 {*             DATALEX.PAS                  *}
 {********************************************}

	  L[36] := 'Do you want to quit the Lation Lexicon';
	  L[37] := ' Exit to Main Menu';
	  L[38] := 'Total_______';
	  L[39] := 'Bonus_______';
	  L[40] := 'You make mistake:';
	  L[41] := ' Mouse options ';
	  L[42] := ' [ ] Reverse mouse buttons ';
	  L[43] := ' Information ';
	  L[44] := ' level';
	  L[45] := 'with this result :';
	  L[46] := 'Total____ ';
	  L[47] := 'Bonus____ ';
	  L[48] := 'All sum__ ';
	  L[49] := 'You are finish';
	  L[50] := 'Answered on ';
	  L[51] := ' pair';
	  L[52] := 'Righ answered';
	  L[53] := 'on ';
	  L[54] := ' pair words';
	  L[55] := 'Exit ';
	  L[56] := 'Change';
	  L[57] := 'Select';
	  L[58] := 'Move';
	  L[59] := 'Use Mouse';
	  L[60] := ' Error ';
	  L[61] := 'File (';
	  L[62] := ') not found';
	  L[63] := ') is not';
	  L[64] := 'Lation Lexicon Vocabulary';
	  L[65] := 'Loading words from ';
	  L[66] := '% Complete';
	  {***** OTHER ******************}
	  L[67] := ' What Difficalty ? ';
	  L[68] := ' Languade         ';
	  L[69] := ' Do you want see this program on RUSSIAN or ENGLISH';
	  L[70] := ' Languade ';
	  L[71] := '  Russian  ';
	  L[72] := '  English  ';
	  L[73] := 'Install load file in menu';
	  L[74] := 'Environment  │  Loading File';
	  L[75] := ' Prompt           ';
	  L[76] := ' Do you want have a prompt in the following all test';
	  L[77] := ' Prompt ';
	  L[78] := '  On  ';
	  L[79] := '  Off ';
	  L[80] := 'Disk is write protected';
	  L[81] := 'Critical disk error';
	  L[82] := 'Help';
	  L[83] := 'Sort';
	  L[84] := 'Do you want give up and not countinue test';
	  L[85] := 'A you sure ?';
	  L[86] := ' Press any key or click the mouse on continue';
	  L[87] := 'Printer not ready';
	  L[88] := 'Device write fault';
	  L[89] := 'Print this words (Y/N) ?';
	  L[90] := ' Do you want to print it pairs words on PRN ?';
	  L[91] := 'Help file LATLEX.HLP not found';
	  L[92] := 'Unexpected end of file reading LATLEX.HLP';
	  L[93] := 'Help file has invalid format';
	  L[95] := 'Insufficient heap space available';
	  L[96] := 'Help initialization error';
	  L[97] := 'Help on help';
	  L[98] := 'Previous help';
	  L[99] := 'Close help';
	  L[100] := ' first';
	  L[101] := ' second';
	  L[102] := ' third';
	  L[103] := ' Mouse            ';
	  L[104] := ' Which mouse button (right or left) is the active one';
	  L[105] := 'By File (';
	  L[106] := ') not found file';
	  L[107] := 'Disk read error';
	  L[108] := 'File not found';
	  L[109] := 'Too many open files';
	  L[110] := 'File access defined';
	  L[111] := ' Compile';
	  L[112] := ' Making from You vocabulary TBL-file (VOC -> TBL)';
	end;
      False :
	begin
 {********************************************}
 {*             MENULEX.PAS                  *}
 {********************************************}

	  L[0] := ' Главное Меню ';
	  L[1] := '   Информация';
	  L[2] := ' Вся информация об этой программе';
	  L[3] := '   Начать тест';
	  L[4] := ' Начать Главный Тест этой программы';
	  L[5] := ' Легкий ';
	  L[6] := ' Легкий уровень сложности имеет один уровень теста (7 слов)';
	  L[7] := ' Средний ';
	  L[8] := ' Средний уровень сложности имеет два уровня теста (14 слов)';
	  L[9] := ' Жесткий ';
	  L[10] := ' Жесткий уровень сложности имеет три уровня теста (21 слово) ';
	  L[11] := '    Окружение ';
	  L[12] := ' Набор опций среды окружения этой программы';
	  L[13] := ' Окружение ';
	  L[14] := ' Помощь           ';
	  L[15] := ' Помощь на русском или английском языке ?';
	  L[16] := ' Загрузочный файл ';
	  L[17] := ' Статистика теста ';
	  L[18] := ' Какой Lation Lexicon файл будет загружаться для Вашего теста';
	  L[19] := '      Выход';
	  L[20] := ' Завершить тест, выйти в DOS';
	  L[21] := ' Предупреждение ';
	  L[22] := ' Текущий файл - библиотека ';
	  L[23] := 'Выбрать файл-библиотеку';
	  L[24] := ' Каталог ';
	  L[25] := '  Всех файлов  ';
	  L[26] := ' Выберете, какие файлы вы хотели бы увидеть ';
	  L[27] := 'Не достаточно памяти для этой операции';
	  L[28] := 'Критическая ошибка';
	  L[29] := 'Устройство не готово';
	  L[30] := 'Ошибка в данных';
	  L[31] := 'Сектор не найден';
	  L[32] := 'Ошибка при установке головок на диске';
	  L[33] := 'Ошибка при записи на устройство';
	  L[34] := 'Сбой аппаратуры';
	  L[35] := 'Сохранение . . .';
 {********************************************}
 {*             DATALEX.PAS                  *}
 {********************************************}

	  L[36] := 'Вы хотите выйти из Lation Lexicon';
	  L[37] := ' Выход в Главное Меню';
	  L[38] := 'Всего_______';
	  L[39] := 'Премия______';
	  L[40] := ' Несоответствие  ';
	  L[41] := ' Определение мыши ';
	  L[42] := ' [ ] Сменить местами кнопки ';
	  L[43] := ' Информация ';
	  L[44] := 'уровень';
	  L[45] := ' с таким результатом';
	  L[46] := 'За тест__ ';
	  L[47] := 'Премия___ ';
	  L[48] := 'Всего____ ';
	  L[49] := 'Вы окончили';
	  L[50] := 'Отвечено на ';
	  L[51] := ' пар ';
	  L[52] := 'Правильно отвечено';
	  L[53] := 'на ';
	  L[54] := ' пар слов';
	  L[55] := 'Выход ';
	  L[56] := 'Сменa';
	  L[57] := 'Выбор';
	  L[58] := 'Двигать';
	  L[59] := 'Используйте мышь';
	  L[60] := ' Ошибка ';
	  L[61] := 'Файл (';
	  L[62] := ') не найден';
	  L[63] := ') не';
	  L[64] := 'Lation Lexicon Библиотека';
	  L[65] := 'Загрузка слов из ';
	  L[66] := '% готово';
	  {***** OTHER ******************}
	  L[67] := ' Какой уровень сложности ';
	  L[68] := ' Ориентация языка ';
	  L[69] := ' Вы хотите видеть эту программу на РУССКОМ или АНГЛИЙСКОМ языке';
	  L[70] := ' Ориентация ';
	  L[71] := '  Русская ';
	  L[72] := '  Английская ';
	  L[73] := 'Установите, где файл-библиотека';
	  L[74] := 'в меню Среда │ Загрузочный файл';
	  L[75] := ' Подсказка        ';
	  L[76] := ' Вы хотите, чтобы после кажого Вашего неправильного ответа появлялась посказка  ';
	  L[77] := ' Подсказка ';
	  L[78] := '  Вкл  ';
	  L[79] := '  Выкл ';
	  L[80] := 'Диск защищен от записи';
	  L[81] := 'Критическая ошибка диска';
	  L[82] := 'Помощь';
	  L[83] := 'Сортировка';
	  L[84] := 'Вы хотите уже "сдаться" и не продолжать тест';
	  L[85] := 'Вы уверены ?';
	  L[86] := ' Нажмите клавишу на клавиатуре или кнопку мыши для продолжения';
	  L[87] := 'Принтер не готов';
	  L[88] := 'Ошибка при записи на устройство';
	  L[89] := 'Отпечатать эти слова (Y/N) ?';
	  L[90] := ' Вы хотите отпечатать эти пары слов на устройстве PRN ?';
	  L[91] := 'Справочный файл LATLEX.HLP не найден';
	  L[92] := 'Неверный формат конца файла LATLEX.HLP';
	  L[93] := 'Неверный формат справочного файла';
	  L[95] := 'Недостаточно опер. памяти для Help''a';
	  L[96] := 'Ошибка чтения файла LATLEX.HLP';
	  L[97] := 'Помощь по Help''у';
	  L[98] := 'Предыдущая помощь';
	  L[99] := 'Закрыть помощь';
	  L[100] := ' первый ';
	  L[101] := ' второй ';
	  L[102] := ' третий ';
	  L[103] := ' Мышь             ';
	  L[104] := ' Нажатие какой кнопки мыши (правой или левой) будет равносильно нажатию [Enter]';
	  L[105] := 'Файлу (';
	  L[106] := ') не найден файл';
	  L[107] := 'Ошибка чтения с диска';
	  L[108] := 'Файл не найден';
	  L[109] := 'Слишком много открытых файлов';
	  L[110] := 'В доступе к файлу отказано';
	  L[111] := ' Компиляция';
	  L[112] := ' Позволяет сделать Вашей библиотеке таблицу (VOC -> TBL)';
       end
    end;{Case}
  end;
 end.
