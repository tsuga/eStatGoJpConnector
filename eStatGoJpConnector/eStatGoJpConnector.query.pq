﻿// Use this file to write queries to test your data connector
let
    result = eStatGoJpConnector.Contents(Text.From("1: 統計情報"))
in
    result