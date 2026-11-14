*** Variables ***
# ── App / Screen Mappings ────────────────────────────────────────────────────
&{APP_ICONS}
...    navigation=id:app-icon-navigation
...    media=id:app-icon-media
...    climate=id:app-icon-climate
...    phone=id:app-icon-phone
...    vehicle=id:app-icon-vehicle
...    settings=id:app-icon-settings
...    camera=id:app-icon-camera
...    weather=id:app-icon-weather

&{APP_SCREENS}
...    navigation=id:screen-navigation
...    media=id:screen-media
...    climate=id:screen-climate
...    phone=id:screen-phone
...    vehicle=id:screen-vehicle
...    settings=id:screen-settings
...    camera=id:screen-camera
...    weather=id:screen-weather

&{APP_TITLES}
...    navigation=NAVIGATION
...    media=MEDIA
...    climate=CLIMATE
...    phone=PHONE
...    vehicle=VEHICLE
...    settings=SETTINGS
...    camera=CAMERA
...    weather=WEATHER

# ── Domain / State Mappings ──────────────────────────────────────────────────
&{OBSTACLE_DISTANCES}
...    clear=Clear
...    medium=1.5 m
...    near=< 0.3 m

&{LANGUAGE_GREETINGS}
...    en=Welcome
...    de=Willkommen
...    fr=Bienvenue
...    tr=Hoş Geldiniz

&{UNIT_LABELS}
...    metric=Metric
...    imperial=Imperial
