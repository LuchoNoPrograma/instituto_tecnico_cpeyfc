// to use myTheme in an application, pass it to the theme grid option
import {iconSetMaterial, themeQuartz} from 'ag-grid-community';

export default themeQuartz
  .withPart(iconSetMaterial)
  .withParams({
    accentColor: "#2F428C",
    browserColorScheme: "inherit",
    columnBorder: true,
    fontFamily: "inherit",
    fontSize: 12,
    foregroundColor: "#161616",
    headerBackgroundColor: "#E9E5E5",
    headerFontSize: 14,
    headerFontWeight: 500,
    spacing: 6
  });
