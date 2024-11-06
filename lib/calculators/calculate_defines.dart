///< Режим расчета и ориентации устройства
///< cdm3D - трехмерный расчет (свободное расположение устройства),
///< cdmVertical - X и Z (вертикальное расположение устройства),
///< cdmHorizontal - X и Y (горизонтальное расположение устройства)
enum CalculateDirectionMode {cdm3D, cdmVertical, cdmHorizontal}

///< Раделитель целой и дробной части числа при экспорте сигнала
///< dsPoint - точка
///< dsComma - запятая
enum DecimalSeparator { dsPoint, dsComma }
