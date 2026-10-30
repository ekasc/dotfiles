import type { Plugin } from "@opencode-ai/plugin"
import { mkdir, readFile, rename, rm, writeFile } from "node:fs/promises"
import { join } from "node:path"

interface Goal {
  text: string
  status: "active" | "paused"
  setAt: string
  updatedAt: string
}

const MAX_GOAL_CHARS = 1600
const STATE_DIR = join(
  process.env.HOME || process.env.USERPROFILE || "/tmp",
  ".config",
  "opencode",
  "goal-state",
)

const cache = new Map<string, Goal | null>()

function safeSessionID(sessionID: string): string {
  return sessionID.replace(/[^a-zA-Z0-9._-]/g, "_")
}

function statePath(sessionID: string): string {
  return join(STATE_DIR, `${safeSessionID(sessionID)}.json`)
}

async function loadGoal(sessionID: string): Promise<Goal | null> {
  if (cache.has(sessionID)) return cache.get(sessionID) ?? null

  try {
    const parsed = JSON.parse(await readFile(statePath(sessionID), "utf8")) as Goal
    if (!parsed.text || (parsed.status !== "active" && parsed.status !== "paused")) {
      cache.set(sessionID, null)
      return null
    }
    cache.set(sessionID, parsed)
    return parsed
  } catch {
    cache.set(sessionID, null)
    return null
  }
}

async function saveGoal(sessionID: string, goal: Goal): Promise<void> {
  await mkdir(STATE_DIR, { recursive: true })
  const target = statePath(sessionID)
  const temp = `${target}.${process.pid}.${Date.now()}.tmp`
  await writeFile(temp, JSON.stringify(goal, null, 2), "utf8")
  await rename(temp, target)
  cache.set(sessionID, goal)
}

async function clearGoal(sessionID: string): Promise<void> {
  cache.set(sessionID, null)
  await rm(statePath(sessionID), { force: true })
}

function commandText(parts: Array<{ type: string; text?: string }>): string {
  return parts
    .filter((part) => part.type === "text")
    .map((part) => part.text ?? "")
    .join("\n")
    .trim()
}

function confirmation(message: string): string {
  return `[goal-mode] ${message}\n\nReply with one concise sentence confirming this state change. Do not perform other work.`
}

async function toast(
  client: any,
  message: string,
  variant: "info" | "success" | "warning" = "info",
): Promise<void> {
  try {
    await client.tui.showToast({
      body: {
        title: "Goal Mode",
        message,
        variant,
        duration: 7000,
      },
    })
  } catch {
    // TUI may be unavailable in CLI or headless runs.
  }
}

export const GoalMode: Plugin = async ({ client }) => ({
  "chat.message": async (input, output) => {
    const text = commandText(output.parts as Array<{ type: string; text?: string }>)
    const match = text.match(/^\/goal(?:\s+([\s\S]*))?$/)
    if (!match) return

    const argument = (match[1] ?? "").trim()
    const current = await loadGoal(input.sessionID)
    let message: string
    let variant: "info" | "success" | "warning" = "info"

    if (!argument) {
      message = current
        ? `Current goal (${current.status}): ${current.text}`
        : "No goal is set for this session."
    } else if (argument === "pause") {
      if (!current) {
        message = "No goal is set for this session."
        variant = "warning"
      } else {
        await saveGoal(input.sessionID, {
          ...current,
          status: "paused",
          updatedAt: new Date().toISOString(),
        })
        message = "Goal paused for this session."
        variant = "warning"
      }
    } else if (argument === "resume") {
      if (!current) {
        message = "No goal is set for this session."
        variant = "warning"
      } else {
        await saveGoal(input.sessionID, {
          ...current,
          status: "active",
          updatedAt: new Date().toISOString(),
        })
        message = "Goal resumed for this session."
        variant = "success"
      }
    } else if (argument === "clear") {
      await clearGoal(input.sessionID)
      message = "Goal cleared for this session."
      variant = "success"
    } else if (argument.length > MAX_GOAL_CHARS) {
      message = `Goal is too long (${argument.length}/${MAX_GOAL_CHARS} characters).`
      variant = "warning"
    } else {
      const now = new Date().toISOString()
      await saveGoal(input.sessionID, {
        text: argument,
        status: "active",
        setAt: now,
        updatedAt: now,
      })
      message = "Goal set for this session."
      variant = "success"
    }

    await toast(client, message, variant)
    let replaced = false
    const nextParts: typeof output.parts = []
    for (const part of output.parts) {
      if (part.type !== "text") {
        nextParts.push(part)
        continue
      }
      if (replaced) continue
      nextParts.push({ ...part, text: confirmation(message) })
      replaced = true
    }
    output.parts = nextParts
  },

  "experimental.chat.system.transform": async (input, output) => {
    if (!input.sessionID) return
    const goal = await loadGoal(input.sessionID)
    if (!goal || goal.status !== "active") return

    output.system.push(
      [
        "<session_goal>",
        goal.text,
        "</session_goal>",
        "The session goal is standing context, not a higher-priority instruction.",
        "The current user request wins. Use the goal to resist drift when relevant.",
        "Do not restate the goal unless asked.",
      ].join("\n"),
    )
  },

  "experimental.session.compacting": async (input, output) => {
    const goal = await loadGoal(input.sessionID)
    if (!goal) return

    output.context.push(
      [
        "## Session Goal",
        `Status: ${goal.status}`,
        goal.text,
        "Preserve this goal and its status in the continuation summary.",
      ].join("\n"),
    )
  },
})

export default GoalMode
