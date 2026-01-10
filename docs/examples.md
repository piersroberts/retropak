# Examples

Real-world examples of Retropak manifests.

---

## Minimal Example

The simplest valid Retropak:

```json
{
  "schemaVersion": "1-0-0",
  "info": {
    "title": "Tetris",
    "platform": "gb"
  },
  "media": [{
    "filename": "software/tetris.gb",
    "type": "cartridge"
  }]
}
```

**Structure:**

```
tetris.rpk
├── retropak.json
└── software/
    └── tetris.gb
```

---

## Complete Example

A fully featured package:

```json
{
  "schemaVersion": "1-0-0",
  "manifestVersion": "2",
  "info": {
    "title": "Sonic the Hedgehog",
    "alternativeTitles": ["ソニック・ザ・ヘッジホッグ"],
    "platform": "md",
    "developer": "Sonic Team",
    "publisher": "Sega",
    "country": "jp",
    "releaseDate": "1991-06-23",
    "description": "Sega's flagship platformer introducing the blue blur. Race through Green Hill Zone at supersonic speed!",
    "category": ["game"],
    "genre": ["platformer", "action"],
    "players": {
      "min": 1,
      "max": 1
    },
    "features": {
      "required": ["gamepad"],
      "supported": ["save_file"]
    },
    "languages": ["en", "ja"],
    "credits": [
      { "name": "Yuji Naka", "roles": ["Lead Programmer"] },
      { "name": "Naoto Ohshima", "roles": ["Character Designer"] },
      { "name": "Masato Nakamura", "roles": ["Composer"] }
    ],
    "externalIds": {
      "igdb": 1234
    },
    "rating": {
      "esrb": "e",
      "pegi": 3
    }
  },
  "media": [{
    "filename": "software/sonic.bin",
    "type": "cartridge",
    "region": "ntsc-u",
    "md5": "d41d8cd98f00b204e9800998ecf8427e",
    "sha1": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
    "status": "good",
    "verified": true,
    "source": "No-Intro",
    "serial": "MK-1491"
  }],
  "assets": {
    "boxFront": {
      "file": "art/box_front.jpg",
      "alt": "Sonic pointing forward with the game logo above"
    },
    "boxBack": {
      "file": "art/box_back.jpg",
      "alt": "Screenshots showing Green Hill Zone and Special Stage"
    },
    "physicalMedia": [{
      "file": "art/cartridge.jpg",
      "alt": "Black Mega Drive cartridge with Sonic artwork",
      "type": "cartridge"
    }],
    "logo": {
      "file": "art/logo.png",
      "alt": "Sonic the Hedgehog logo with blue blur effect"
    },
    "backdrop": {
      "file": "art/backdrop.jpg",
      "alt": "Green Hill Zone landscape with checkered hills and palm trees"
    },
    "titleScreen": {
      "file": "art/title.png",
      "alt": "Title screen with Sonic and logo on blue background"
    },
    "gameplay": [
      {
        "file": "art/gameplay1.png",
        "alt": "Sonic running through loop-de-loop in Green Hill Zone"
      },
      {
        "file": "art/gameplay2.png",
        "alt": "Sonic collecting rings near checkpoint"
      }
    ],
    "manual": "docs/manual.pdf",
    "music": [{
      "title": "Green Hill Zone",
      "file": "audio/green_hill.mp3",
      "background": true
    }]
  }
}
```

---

## Multi-Disc Example

PlayStation game with multiple discs:

```json
{
  "schemaVersion": "1-0-0",
  "info": {
    "title": "Final Fantasy VII",
    "platform": "psx",
    "developer": "Square",
    "publisher": "Square",
    "releaseDate": "1997-01-31",
    "category": ["game"],
    "genre": ["rpg"],
    "players": { "min": 1, "max": 1 }
  },
  "media": [
    {
      "filename": "software/ff7_disc1.bin",
      "label": "Disc 1",
      "type": "cdrom",
      "index": 1, // (1)!
      "bootable": true, // (2)!
      "region": "ntsc-u"
    },
    {
      "filename": "software/ff7_disc2.bin",
      "label": "Disc 2",
      "type": "cdrom",
      "index": 2,
      "bootable": false, // (3)!
      "region": "ntsc-u"
    },
    {
      "filename": "software/ff7_disc3.bin",
      "label": "Disc 3",
      "type": "cdrom",
      "index": 3,
      "bootable": false,
      "region": "ntsc-u"
    }
  ],
  "assets": {
    "boxFront": {
      "file": "art/box_front.jpg",
      "alt": "Cloud Strife with Meteor in background"
    },
    "physicalMedia": [
      {
        "file": "art/disc1.jpg",
        "alt": "Disc 1 with Cloud artwork",
        "mediaId": "disc1",
        "type": "cdrom"
      },
      {
        "file": "art/disc2.jpg",
        "alt": "Disc 2 with Aerith artwork",
        "mediaId": "disc2",
        "type": "cdrom"
      },
      {
        "file": "art/disc3.jpg",
        "alt": "Disc 3 with Sephiroth artwork",
        "mediaId": "disc3",
        "type": "cdrom"
      }
    ]
  }
}
```

1. Order matters! Use sequential indices starting at 1
2. Only the first disc is bootable - this is what the emulator loads initially
3. Subsequent discs are swapped during gameplay

!!! info "Multi-Disc Games"
    For sequential disc games, only mark the first disc as `bootable: true`. The emulator will prompt for disc swaps when needed.

---

## Compilation Example

!!! tip "Compilations vs Separate Retropaks"
    Use `type: "compilation"` for official multi-game releases like Namco Museum. For unrelated games, create separate `.rpk` files instead.

Multi-game compilation disc:

```json
{
  "schemaVersion": "1-0-0",
  "info": {
    "title": "Namco Museum Vol. 1",
    "platform": "psx",
    "developer": "Namco",
    "publisher": "Namco",
    "releaseDate": "1995-11-22",
    "type": "compilation",
    "contents": [ // (1)!
      "Pac-Man",
      "Galaga",
      "Pole Position",
      "Rally-X",
      "New Rally-X",
      "Bosconian",
      "Toy Pop"
    ],
    "category": ["game"],
    "genre": ["arcade"]
  },
  "media": [{
    "filename": "software/namco_museum.bin",
    "type": "cdrom",
    "region": "ntsc-u"
  }],
  "assets": {
    "boxFront": {
      "file": "art/box_front.jpg",
      "alt": "Namco Museum logo with classic arcade character sprites"
    }
  }
}
```

1. List all included games for searchability and filtering

---

## Homebrew Example

Modern homebrew game:

```json
{
  "schemaVersion": "1-0-0",
  "info": {
    "title": "Micro Mages",
    "platform": "nes",
    "developer": "Morphcat Games",
    "releaseDate": "2019-07-13",
    "description": "A modern 4-player platform game for the NES.",
    "category": ["game", "homebrew"],
    "genre": ["platformer"],
    "players": {
      "min": 1,
      "max": 4,
      "coop": true
    },
    "features": {
      "supported": ["multitap"]
    },
    "languages": ["en"]
  },
  "media": [{
    "filename": "software/micro_mages.nes",
    "type": "cartridge",
    "status": "good",
    "verified": true,
    "source": "Homebrew DB"
  }],
  "assets": {
    "boxFront": {
      "file": "art/box_front.png",
      "alt": "Four mages in different colors standing together"
    },
    "logo": {
      "file": "art/logo.png",
      "alt": "Micro Mages pixel art logo"
    }
  }
}
```

---

## Sega Channel Example

Digital distribution format:

```json
{
  "schemaVersion": "1-0-0",
  "info": {
    "title": "Streets of Rage 2",
    "platform": "md",
    "developer": "Sega",
    "publisher": "Sega",
    "releaseDate": "1992-12-20",
    "category": ["game"],
    "genre": ["beat_em_up"],
    "notes": "Originally distributed via Sega Channel cable service"
  },
  "media": [{
    "filename": "software/sor2.bin",
    "type": "download",
    "notes": "Sega Channel version",
    "region": "ntsc-u"
  }]
}
```

---

## DOS Game Example

PC game with multiple files:

```json
{
  "schemaVersion": "1-0-0",
  "info": {
    "title": "DOOM",
    "platform": "dos",
    "developer": "id Software",
    "publisher": "id Software",
    "releaseDate": "1993-12-10",
    "category": ["game"],
    "genre": ["fps"],
    "features": {
      "required": ["keyboard", "mouse"],
      "supported": ["online"]
    },
    "rating": {
      "esrb": "m"
    }
  },
  "media": [{
    "filename": "software/doom.zip",
    "type": "archive",
    "notes": "Contains DOOM.EXE and WAD files"
  }],
  "config": [{
    "file": "config/dosbox.conf",
    "target": "dosbox",
    "description": "Optimized DOSBox settings for DOOM"
  }]
}
```

---

## With Copy Protection

Game requiring code wheel:

```json
{
  "schemaVersion": "1-0-0",
  "info": {
    "title": "King's Quest V",
    "platform": "dos",
    "developer": "Sierra On-Line",
    "publisher": "Sierra On-Line",
    "notes": "Requires code wheel for copy protection. See docs/codewheel.pdf"
  },
  "media": [{
    "filename": "software/kq5.zip",
    "type": "archive"
  }],
  "assets": {
    "manual": "docs/manual.pdf"
  },
  "config": [{
    "file": "docs/codewheel.pdf",
    "description": "Copy protection code wheel reference"
  }]
}
```

---

## More Examples

The examples above demonstrate the core features of Retropak manifests:

- Peripheral requirements (light guns, dance mats, etc.)
- Alternative titles and localizations
- Beta/prototype releases
- Hacks and translations
- Educational software
- Applications and demos

[View specification →](specification.md)
