--- A live connection returned by `packet:on()`, `packet:once()`, or `scope:on()`.
export type Connection = {
    --- Whether the connection is still active.
    connected: boolean,
    --- Disconnects and prevents further callbacks from firing.
    disconnect: (self: Connection) -> (),
}

--- A one-way typed network channel.
export type Packet<T> = {
    --- Sends data over the channel.
    --- Server: `target` is required (Player, Group, array, or `Lync.all`).
    --- Client: `target` must be omitted.
    send: (self: Packet<T>, data: T, target: any?) -> (),
    --- Registers a persistent callback that fires on every received packet.
    --- Returns a Connection that can be disconnected.
    on: (self: Packet<T>, fn: (data: T, sender: Player?, timestamp: number?) -> ()) -> Connection,
    --- Registers a one-shot callback that fires once then disconnects itself.
    once: (self: Packet<T>, fn: (data: T, sender: Player?, timestamp: number?) -> ()) -> Connection,
    --- Yields the current thread until the next packet is received.
    --- Returns `(data, sender, timestamp)`.
    wait: (self: Packet<T>) -> (T, Player?, number?),
    --- Returns the registered name of this packet.
    name: (self: Packet<T>) -> string,
    --- Returns byte/fire counters for this packet. Requires `Lync.configure({ stats = true })`.
    stats: (self: Packet<T>) -> PacketStats,
}

--- A request–response pair. The server or client can be either side depending on who calls `handle`.
export type Query<Req, Resp> = {
    --- Registers a handler that responds to incoming requests.
    --- `fn` receives the request data and the sender (nil on client) and must return the response.
    handle: (self: Query<Req, Resp>, fn: (request: Req, player: Player?) -> Resp?) -> Connection,
    --- Sends a request and yields until a response is received (or the timeout elapses).
    --- Server: `target` is a single Player for a `Resp?` result.
    request: (self: Query<Req, Resp>, data: Req, target: any?) -> Resp?,
    --- Returns the registered name of this query.
    name: (self: Query<Req, Resp>) -> string,
    --- Returns byte/fire counters for this query. Requires `Lync.configure({ stats = true })`.
    stats: (self: Query<Req, Resp>) -> PacketStats,
}

--- A named, auto-cleaned set of players. Members are removed automatically on `PlayerRemoving`.
export type Group = {
    --- Adds a player to the group. Returns `true` if the player was newly added.
    add: (self: Group, player: Player) -> boolean,
    --- Removes a player from the group. Returns `true` if the player was present.
    remove: (self: Group, player: Player) -> boolean,
    --- Returns `true` if the player is currently in the group.
    has: (self: Group, player: Player) -> boolean,
    --- Returns the current member count.
    count: (self: Group) -> number,
    --- Destroys the group and removes all members.
    destroy: (self: Group) -> (),
}

--- Batches connections for bulk cleanup. Accepts Lync Connections and RBXScriptConnections.
export type Scope = {
    --- Calls `source:on(fn)` and tracks the returned connection.
    on: (self: Scope, source: any, fn: (...any) -> ()) -> Connection,
    --- Calls `source:once(fn)` and tracks the returned connection.
    once: (self: Scope, source: any, fn: (...any) -> ()) -> Connection,
    --- Manually adds an existing connection to be tracked by this scope.
    add: (self: Scope, connection: any) -> (),
    --- Returns the number of tracked connections.
    size: (self: Scope) -> number,
    --- Disconnects all tracked connections and clears the scope.
    destroy: (self: Scope) -> (),
}

--- Per-packet bandwidth and fire counters.
export type PacketStats = {
    bytesSent: number,
    bytesReceived: number,
    fires: number,
    recvFires: number,
    drops: number,
}

--- Per-player bandwidth counters (server-side only).
export type PlayerStats = {
    bytesSent: number,
    bytesReceived: number,
}

--- Token-bucket or cooldown rate-limit configuration.
export type RateLimitConfig = {
    --- Maximum accepts per second (token-bucket).
    maxPerSecond: number?,
    --- Burst allowance above `maxPerSecond`.
    burst: number?,
    --- Fixed cooldown in seconds between accepts.
    cooldown: number?,
}

--- Options accepted by `Lync.packet()`.
export type PacketOptions = {
    --- If `true`, sends over an unreliable channel (lower latency, no order guarantee, no delta codecs).
    unreliable: boolean?,
    rateLimit: RateLimitConfig?,
    --- Custom server-side validator. Return `(true, nil)` to accept, `(false, reason)` to reject.
    validate: ((data: any, player: Player) -> (boolean, string?))?,
    --- Maximum allowed payload size in bytes. Packets exceeding this are dropped.
    maxPayloadBytes: number?,
    --- Attaches a timestamp to each packet. `"frame"` = 1-byte frame delta, `"offset"` = 2-byte, `"full"` = 8-byte Unix.
    timestamp: ("frame" | "offset" | "full")?,
}

--- Options accepted by `Lync.query()`.
export type QueryOptions = {
    --- Seconds before an unanswered request is abandoned. Defaults to 5.
    timeout: number?,
    rateLimit: RateLimitConfig?,
    validate: ((data: any, player: Player) -> (boolean, string?))?,
}

--- Options accepted by `Lync.configure()`. Must be called before `Lync.start()`.
export type ConfigureOptions = {
    --- Maximum channel buffer size in bytes (4096–1048576).
    channelMaxSize: number?,
    --- Maximum struct/array nesting depth validated by Gate (4–32).
    validationDepth: number?,
    --- Internal buffer pool size (2–128).
    poolSize: number?,
    bandwidthLimit: { softLimit: number, maxStrikes: number }?,
    globalRateLimit: { maxPerSecond: number }?,
    --- Enables per-packet byte/fire counters accessible via `packet:stats()`.
    stats: boolean?,
}

return table.freeze({})
