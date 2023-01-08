local HTTPService = game:GetService("HttpService")

-- TODO Test to ensure this data is properly decoded and works as intended.
local Data = [[
    {
    "ModerationEntries": {
      "\"0000000003\"": {
        "AppealStatus": "Un-Appealed",
        "BanType": "Player",
        "Description": "N/A",
        "Flags": [
          "Exploiting",
          "Undesirable"
        ],
        "ModeratorUserId": 1794584685,
        "UserId": 13130330
      },
      "NextModerationEntryNumber": 1
    },
    "PlayerEntries": {
      "964361": {
        "DangerLevel": "High",
        "Flags": [
          "nil"
        ],
        "InvalidModerationEntries": [
          "nil"
        ],
        "ModerationEntries": [
          "0000000002"
        ],
        "Notes": [
          "nil"
        ]
      },
      "13130330": {
        "DangerLevel": "High",
        "Flags": [
          "nil"
        ],
        "InvalidModerationEntries": [
          "nil"
        ],
        "ModerationEntries": [
          "0000000003"
        ],
        "Notes": [
          "nil"
        ]
      },
      "1794584685": {
        "DangerLevel": "Low",
        "Flags": [
          "nil"
        ],
        "InvalidModerationEntries": [
          "nil"
        ],
        "ModerationEntries": [
          "nil",
          "0000000004"
        ],
        "Notes": [
          "nil"
        ]
      }
    }
  }
]]
return HTTPService:JSONDecode(Data)
