import { themeQuartz, iconSetMaterial } from 'ag-grid-community';

// to use myTheme in an application, pass it to the theme grid option
const myTheme = themeQuartz
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
