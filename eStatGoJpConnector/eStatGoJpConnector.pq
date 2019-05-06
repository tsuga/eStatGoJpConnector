section eStatGoJpConnector;

[DataSource.Kind="eStatGoJpConnector", Publish="eStatGoJpConnector.Publish"]
shared eStatGoJpConnector.Nav = Value.ReplaceType(eStatGoJpConnectorNavImpl, eStatGoJpConnectorNavType);

eStatGoJpConnectorNavType = type function (
    searchKind as (type text meta [
        Documentation.FieldCaption = Extension.LoadString("Type.searchKind.Documentation.FieldCaption"),
        Documentation.FieldDescription = Extension.LoadString("Type.searchKind.Documentation.FieldDescription"),
        Documentation.AllowedValues = { "1: 統計情報", "2: 小地域・地域メッシュ", "3: 社会・人口統計体系（都道府県・市区町村のすがた）"}
    ]),
    optional lang as (type text meta [
        Documentation.FieldCaption = Extension.LoadString("Type.lang.Documentation.FieldCaption"),
        Documentation.FieldDescription = Extension.LoadString("Type.lang.Documentation.FieldDescription"),
        Documentation.AllowedValues = { "J: 日本語 (Japanese)", "E: 英語 (English)" }
    ]))
    as table meta [
        Documentation.Name =  Extension.LoadString("Type.table.Documentation.Name"),
        Documentation.LongDescription = Extension.LoadString("Type.table.Documentation.LongDescription"),
        Documentation.Examples = {}
    ];

eStatGoJpConnectorNavImpl = (searchKind as text, optional lang as text) as table =>
    let
        credentials = Extension.CurrentCredential(),
        apiKey = credentials[Password],
        _lang = if (lang <> null) then Text.At(lang, 0) else "J",
        _url = "https://api.e-stat.go.jp/rest/2.1/app/json/getStatsList?appId=" & apiKey & "&statsNameList=Y&searchKind=" & Text.At(searchKind, 0),
        _response = Web.Contents(_url, [Timeout =  #duration(0,0,0,2000), Headers=[#"Authorization" = ""]]),
        objects1 = Json.Document(_response),
        objects2 = Table.FromRecords(objects1[GET_STATS_LIST][DATALIST_INF][LIST_INF]),
        objects3 = Table.ExpandRecordColumn(objects2, "STAT_NAME", {"@code", "$"}, {"STATID_","STATNAME_"}),
        objects4 = Table.ExpandRecordColumn(objects3, "GOV_ORG", {"$"}, {"GOVORG_"}),
        objects5 = Table.AddColumn(objects4, "Name", each [STATNAME_] & " - " & [GOVORG_] & " (" & [STATID_] & ")"),
        objects6 = Table.AddColumn(objects5, "Key", each [STATID_]),
        objects7 = Table.AddColumn(objects6, "ItemKind", each "Folder"),
        objects8 = Table.AddColumn(objects7, "Data",  each CreateNavTableLevel1(Extension.CurrentCredential(), [STATID_], _lang)),
        objects9 = Table.AddColumn(objects8, "ItemName",  each "Folder"),
        objects10 = Table.AddColumn(objects9, "IsLeaf",  each false),
        objects11 = Table.RemoveColumns(objects10, {"@id", "STATID_", "STATNAME_", "GOVORG_", "STATISTICS_NAME_SPEC", "TITLE_SPEC"}),
        NavTable = Table.ToNavigationTable(objects11, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        NavTable;



// Data Source Kind description
eStatGoJpConnector = [
    TestConnection = (dataSourcePath) => { "eStatGoJpConnector.Contents", dataSourcePath },
    Authentication = [
        Key = [
            KeyLabel = Extension.LoadString("appIdKeyLabel"),
            Label = Extension.LoadString("appIdLabel")
		]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
eStatGoJpConnector.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://github.com/tsuga/eStatGoJpConnector",
    SourceImage = eStatGoJpConnector.Icons,
    SourceTypeImage = eStatGoJpConnector.Icons
];

eStatGoJpConnector.Icons = [
    Icon16 = { Extension.Contents("eStatGoJpConnector16.png"), Extension.Contents("eStatGoJpConnector20.png"), Extension.Contents("eStatGoJpConnector24.png"), Extension.Contents("eStatGoJpConnector32.png") },
    Icon32 = { Extension.Contents("eStatGoJpConnector32.png"), Extension.Contents("eStatGoJpConnector40.png"), Extension.Contents("eStatGoJpConnector48.png"), Extension.Contents("eStatGoJpConnector64.png") }
];


CreateNavTableLevel1 = (credentials as any, statId as text, optional lang as text) as table => 
    let
        apiKey = credentials[Password],
        _lang = if (lang <> null) then Text.At(lang, 0) else "J",
        _url = "https://api.e-stat.go.jp/rest/2.1/app/json/getStatsList?appId=" & apiKey & "&statsCode=" & statId,
        _response = Web.Contents(_url, [Timeout =  #duration(0,0,0,2000), Headers=[#"Authorization" = ""]]),
        objects1 = Json.Document(_response),
        objects2 = if Value.Is(objects1[GET_STATS_LIST][DATALIST_INF][TABLE_INF], Record.Type) then Table.FromRecords({objects1[GET_STATS_LIST][DATALIST_INF][TABLE_INF]}) else Table.FromRecords(objects1[GET_STATS_LIST][DATALIST_INF][TABLE_INF]),
        objects3 = Table.SelectColumns(objects2, {"SURVEY_DATE"}),
        objects4 = Table.Distinct(objects3),
        objects5 = Table.AddColumn(objects4, "Name", each Extension.LoadString("SurveyYearMonth") & ": " & (if [SURVEY_DATE] = 0 then "なし" else Text.From([SURVEY_DATE]))),        
        objects6 = Table.AddColumn(objects5, "Key", each Text.From([SURVEY_DATE])),
        objects7 = Table.AddColumn(objects6, "Data",  each CreateNavTableLevel2(Extension.CurrentCredential(), statId, Text.From([SURVEY_DATE]), _lang)),
        objects8 = Table.AddColumn(objects7, "ItemKind", each "View"),
        objects9 = Table.AddColumn(objects8, "ItemName",  each "View"),
        objects10 = Table.AddColumn(objects9, "IsLeaf",  each false),
        objects11 = Table.RemoveColumns(objects10, {"SURVEY_DATE"}),
        NavTable = Table.ToNavigationTable(objects11, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        NavTable;

CreateNavTableLevel2 = (credentials as any, statId as text, surveyYears as text, optional lang as text) as table => 
    let
        apiKey = credentials[Password],
        _lang = if (lang <> null) then Text.At(lang, 0) else "J",
        _url_pre = "https://api.e-stat.go.jp/rest/2.1/app/json/getStatsList?appId=" & apiKey & "&statsCode=" & statId,
        _url = if surveyYears <> "0" then (_url_pre & "&surveyYears=" & surveyYears) else _url_pre,
        _response = Web.Contents(_url, [Timeout =  #duration(0,0,0,2000), Headers=[#"Authorization" = ""]]),
        objects1 = Json.Document(_response),
        objects2 = if Value.Is(objects1[GET_STATS_LIST][DATALIST_INF][TABLE_INF], Record.Type) then Table.FromRecords({objects1[GET_STATS_LIST][DATALIST_INF][TABLE_INF]}) else Table.FromRecords(objects1[GET_STATS_LIST][DATALIST_INF][TABLE_INF]),
        objects3 = if Value.Is(objects2{0}[TITLE], Record.Type) then Table.ExpandRecordColumn(objects2, "TITLE", {"@no", "$"}, {"NO_","Title_"}) else objects2,
        objects4 = if Value.Is(objects2{0}[TITLE], Record.Type) then Table.AddColumn(objects3, "Name", each "[" & [NO_] & "] " & [Title_]) else Table.AddColumn(objects3, "Name", each [TITLE]),
        objects5 = Table.RenameColumns(objects4, {"@id", "Key"}),
        objects6 = Table.AddColumn(objects5, "Data",  each GetStatsTable(Extension.CurrentCredential(), [Key], _lang)),
        objects7 = Table.AddColumn(objects6, "ItemKind", each "Table"),
        objects8 = Table.AddColumn(objects7, "ItemName",  each "Table"),
        objects9 = Table.AddColumn(objects8, "IsLeaf",  each true),
        objects10 = Table.SelectColumns(objects9, {"Name", "Key", "Data", "ItemKind", "ItemName", "IsLeaf"}),
        NavTable = Table.ToNavigationTable(objects10, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        NavTable;


GetStatsTable = (credentials as any, statsDataId as text, optional lang as text, optional nextKey as text) as table => 
    let
        apiKey = credentials[Password],
        _lang = if (lang <> null) then Text.At(lang, 0) else "J",

        _url_pre = "https://api.e-stat.go.jp/rest/2.1/app/getSimpleStatsData?appId=" & apiKey & "&lang=" & _lang & "&statsDataId=" & statsDataId,
        _url = if (nextKey = null) then _url_pre else _url_pre & "&startPosition=" & nextKey,
        _response = Web.Contents(_url, [Timeout =  #duration(0,0,0,2000), Headers=[#"Authorization" = ""]]),

        src = Lines.FromBinary(_response),
        
        findCombine = Text.Combine(List.FirstN(src, 30), "#(lf)"),
        findCsv = Csv.Document(findCombine, null, null, ExtraValues.Ignore),
        findAddIndex = Table.AddIndexColumn(findCsv, "Index", 0, 1),

        targetNextKey = Table.SelectRows(findAddIndex, each ([Column1] = "NEXT_KEY")),
        nextExists = if Table.RowCount(targetNextKey) = 1 then true else false,
        next_key_index = if nextExists then targetNextKey{0}[Index] else 0,
        nextFindCombine = if nextExists then List.Last(List.FirstN(src, next_key_index+1)) else null,
        nextFindCsv =  if nextExists then Csv.Document(nextFindCombine, null, null, ExtraValues.Ignore) else null,
        _next_key = if nextExists then nextFindCsv{0}[Column2] else null,
        targetValueIndex = Table.SelectRows(findAddIndex, each ([Column1] = "VALUE")){0}[Index],

        skip = List.Skip(src, targetValueIndex + 1),
        
        combine = Text.Combine(skip, "#(lf)"),
        csv = Csv.Document(combine),
        promoted = Table.PromoteHeaders(csv),
        table = if nextExists then Table.Combine({promoted, GetStatsTable(credentials, statsDataId, _lang, _next_key)}) else promoted
    in
        table;


// Common library code

Table.ToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(table),
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta 
        [
            NavigationTable.NameColumn = nameColumn, 
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn, 
            Preview.DelayColumn = itemNameColumn, 
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(table, newTableType)
    in
        navigationTable;