-- Type definitions for axp3cter/lync@2.1.2

-- Opaque handle representing a codec for values of type T.
-- The phantom field `_phantom` is never present at runtime but lets Luau
-- track and infer the encoded/decoded value type through generic functions.
export type Codec<T> = { _lyncCodec: "Codec", _phantom: T? }

-- Codecs that double as a callable for quantized/capped variants.
export type StringCodec = Codec<string> & ((maxLength: number) -> Codec<string>)
export type VecCodec<T> = Codec<T> & ((min: number, max: number, precision: number) -> Codec<T>)
export type CFrameCodec = Codec<CFrame> & (() -> Codec<CFrame>)

-- Returned by packet:on(), query:handle(), and middleware registration.
export type Connection = {
    connected: boolean,
    disconnect: (self: Connection) -> (),
}

-- Named set of players. Members are auto-removed on PlayerRemoving.
export type Group = {
    add:     (self: Group, player: Player) -> boolean,
    remove:  (self: Group, player: Player) -> boolean,
    has:     (self: Group, player: Player) -> boolean,
    count:   (self: Group) -> number,
    destroy: (self: Group) -> (),
}

-- Valid server-side send targets.
export type Target =
    Player
    | Group
    | { Player }
    | { _lyncAll: true }
    | { _lyncExcept: true }

-- Batches connections for bulk cleanup.
export type Scope = {
    on:      (self: Scope, source: Packet<any>, fn: (...any) -> ()) -> Connection,
    once:    (self: Scope, source: Packet<any>, fn: (...any) -> ()) -> Connection,
    add:     (self: Scope, connection: Connection) -> (),
    destroy: (self: Scope) -> (),
}

-- Per-packet counters. Requires Lync.configure({ stats = true }).
export type PacketStats = {
    bytesSent:     number,
    bytesReceived: number,
    fires:         number,
    recvFires:     number,
    drops:         number,
}

-- A defined one-way channel.
export type Packet<T> = {
    -- Server: requires a Target. Client: no target.
    send:  (self: Packet<T>, data: T, target: Target?) -> (),
    on:    (self: Packet<T>, fn: (data: T, sender: Player?, timestamp: number?) -> ()) -> Connection,
    once:  (self: Packet<T>, fn: (data: T, sender: Player?, timestamp: number?) -> ()) -> Connection,
    wait:  (self: Packet<T>) -> (T, Player?, number?),
    name:  (self: Packet<T>) -> string,
    stats: (self: Packet<T>) -> PacketStats,
}

-- A defined request-response channel (consumes two packet IDs internally).
export type Query<TReq, TRes> = {
    -- Server: fn(request, player) -> response. Client: fn(request) -> response.
    handle:  (self: Query<TReq, TRes>, fn: (request: TReq, player: Player?) -> TRes) -> Connection,
    -- Client yields for TRes?. Server single-target yields for TRes?.
    request: (self: Query<TReq, TRes>, data: TReq, target: (Target | Player)?) -> TRes?,
    name:    (self: Query<TReq, TRes>) -> string,
    stats:   (self: Query<TReq, TRes>) -> PacketStats,
}

-- Token bucket or cooldown rate limiting options.
export type RateLimitConfig =
    { maxPerSecond: number, burst: number? }
    | { cooldown: number }

-- Options for Lync.packet().
export type PacketOptions = {
    unreliable:      boolean?,
    rateLimit:       RateLimitConfig?,
    validate:        ((data: any, player: Player) -> (boolean, string?))?,
    maxPayloadBytes: number?,
    timestamp:       ("frame" | "offset" | "full")?,
}

-- Options for Lync.query().
export type QueryOptions = {
    timeout:   number?,
    rateLimit: RateLimitConfig?,
    validate:  ((data: any, player: Player) -> (boolean, string?))?,
}

-- Options for Lync.configure(). Must be called before Lync.start().
export type ConfigureOptions = {
    channelMaxSize:  number?,
    validationDepth: number?,
    poolSize:        number?,
    bandwidthLimit:  { softLimit: number, maxStrikes: number }?,
    globalRateLimit: { maxPerSecond: number }?,
    stats:           boolean?,
}

-- Per-player bandwidth stats (server only).
export type PlayerStats = {
    bytesSent:     number,
    bytesReceived: number,
}

-- Entry in the array returned by Lync.debug.registrations().
export type Registration = {
    name:         string,
    id:           number,
    kind:         string,
    isUnreliable: boolean,
}

export type LyncLib = {
    -- Lifecycle -------------------------------------------------------
    configure: (options: ConfigureOptions) -> (),
    start:     () -> (),
    started:   boolean,
    flush:     () -> (),
    flushRate: (hz: number) -> (),

    -- Definitions -----------------------------------------------------
    packet: <T>(name: string, codec: Codec<T>, options: PacketOptions?) -> Packet<T>,
    query:  <TReq, TRes>(name: string, requestCodec: Codec<TReq>, responseCodec: Codec<TRes>, options: QueryOptions?) -> Query<TReq, TRes>,
    group:  (name: string) -> Group,
    scope:  () -> Scope,

    -- Targeting -------------------------------------------------------
    all:    { _lyncAll: true },
    except: (...any) -> { _lyncExcept: true },
    DROP:   { _lyncDrop: true },

    -- Middleware -------------------------------------------------------
    onSend:    (fn: (data: any, name: string, player: Player?) -> any) -> Connection,
    onReceive: (fn: (data: any, name: string, player: Player?) -> any) -> Connection,
    onDrop:    (fn: (player: Player, reason: string, name: string, data: any?) -> ()) -> Connection,

    -- Stats -----------------------------------------------------------
    stats: {
        player: (player: Player) -> PlayerStats?,
        reset:  () -> (),
    },

    -- Debug -----------------------------------------------------------
    debug: {
        pending:       () -> number,
        registrations: () -> { Registration },
    },

    -- Primitive codecs ------------------------------------------------
    int:    (min: number, max: number) -> Codec<number>,
    float:  (min: number, max: number, precision: number) -> Codec<number>,
    f16:    Codec<number>,
    f32:    Codec<number>,
    f64:    Codec<number>,
    bool:   Codec<boolean>,
    string: StringCodec,
    buff:   Codec<buffer>,

    -- Roblox type codecs ----------------------------------------------
    vec2:           VecCodec<Vector2>,
    vec3:           VecCodec<Vector3>,
    cframe:         CFrameCodec,
    color3:         Codec<Color3>,
    inst:           Codec<Instance>,
    udim:           Codec<UDim>,
    udim2:          Codec<UDim2>,
    numberRange:    Codec<NumberRange>,
    rect:           Codec<Rect>,
    ray:            Codec<Ray>,
    vec2int16:      Codec<Vector2int16>,
    vec3int16:      Codec<Vector3int16>,
    region3:        Codec<Region3>,
    region3int16:   Codec<Region3int16>,
    numberSequence: Codec<NumberSequence>,
    colorSequence:  Codec<ColorSequence>,

    -- Composite codecs ------------------------------------------------
    struct:      <T>(schema: { [string]: Codec<any> }) -> Codec<T>,
    deltaStruct: <T>(schema: { [string]: Codec<any> }) -> Codec<T>,
    array:       <T>(codec: Codec<T>, maxCount: number?) -> Codec<{ T }>,
    deltaArray:  <T>(codec: Codec<T>, maxCount: number?) -> Codec<{ T }>,
    map:         <K, V>(keyCodec: Codec<K>, valueCodec: Codec<V>, maxCount: number?) -> Codec<{ [K]: V }>,
    deltaMap:    <K, V>(keyCodec: Codec<K>, valueCodec: Codec<V>, maxCount: number?) -> Codec<{ [K]: V }>,
    optional:    <T>(codec: Codec<T>) -> Codec<T?>,
    tuple:       (...Codec<any>) -> Codec<any>,
    tagged:      <T>(tagField: string, variants: { [string]: Codec<any> }) -> Codec<T>,

    -- Meta codecs -----------------------------------------------------
    enum:     (...string) -> Codec<string>,
    bitfield: (schema: { [string]: number }) -> Codec<{ [string]: number }>,
    custom:   (
        size:  number,
        write: (b: buffer, offset: number, value: any) -> (),
        read:  (b: buffer, offset: number) -> any
    ) -> Codec<any>,
    nothing: Codec<nil>,
    unknown: Codec<unknown>,
    auto:    Codec<any>,
}

return {}
