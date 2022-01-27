import os, sys, signal, asyncio, threading
from utilities import *

try:
    import discord
    import discord.utils
except: error("Discord library")

channel = None
message = None

intents = discord.Intents.default()
bot = discord.Client(intents = intents)

controls = ["u", "d", "l", "r"]
reactions = ["\u2B06", "\u2B07", "\u2B05", "\u27A1"]

colors = [
    0xFF004D, 0xFFCCAA, 0xFF77A8, 0x83769C,
    0x29ADFF, 0x00E436, 0xFFEC27, 0xFFA300,
]

def error(string):
    print(f"Error: no {string} found!")
    sys.exit(1)

@bot.event
async def on_ready():
    global bot, colors, channel, message, reactions
    name = "pico-8"
    guild = bot.guilds[0]
    channel = discord.utils.get(guild.channels, name = name)
    if not channel: channel = await guild.create_text_channel(name)
    await channel.purge()
    index = 0
    color = colors[index]
    title = "Pico-8 Controller"
    url = "https://i.imgur.com/VOrs3tU.png"
    description = "Use the emoticons or type U, D, L, R\nBy Camden!"
    embed = discord.Embed(title = title, description = description, color = color)
    embed.set_thumbnail(url = url)
    message = await channel.send(embed = embed)
    for reaction in reactions: await message.add_reaction(reaction)
    while True:
        if index == len(colors) - 1: index = 0
        else: index += 1
        await asyncio.sleep(1.5)
        color = colors[index]
        embed = discord.Embed(title = title, description = description, color = color)
        embed.set_thumbnail(url = url)
        await message.edit(embed = embed)

async def on_end():
    global colors, channel
    color = colors[0]
    await channel.purge()
    await channel.send(embed = discord.Embed(description = "Offline  :octagonal_sign:", color = color))

@bot.event
async def on_reaction_add(reaction, user):
    global bot, message, reactions
    if message == reaction.message and user != bot.user:
        await reaction.remove(user)
        reaction = reaction.emoji
        print(f"{user.name.capitalize()} reacted!")
        g.write = controls[reactions.index(reaction)]

@bot.event
async def on_message(message):
    global bot, channel, controls
    if message.channel == channel and message.author != bot.user:
        lower = message.content.lower()
        if lower in controls:
            await message.add_reaction("\u2705")
            print(f"{message.author.name.capitalize()} sent a message!")
            g.write = message.content.lower()
        else: await message.add_reaction("\U0001F6D1")

async def updater():
    global bot, channel
    old = None
    while g.on and g.p8.poll() == None:
        await asyncio.sleep(0.5)
        if g.read and g.read != old:
            string = g.read.split()[0]
            old = g.read
            if string == "coins": await channel.send("**You got a  :coin:**")
            elif string == "gems": await channel.send("**You got a  :gem:**")
    try:
        await on_end()
        await bot.close()
    except: pass

async def start(bot, token): await asyncio.gather(*[updater(), bot.start(token)])

def main():
    global bot
    get()
    g.on = True
    g.p8 = sub()
    data = g.p8.stdout.read(1)
    data = int.from_bytes(data, "big")
    data = 1
    if data == 1:
        print("An experiment by Camden!")
        reading_thread = threading.Thread(target = from_pico8)
        writing_thread = threading.Thread(target = to_pico8)
        reading_thread.start()
        writing_thread.start()
        loop = asyncio.get_event_loop()
        try: loop.run_until_complete(start(bot, g.token))
        except: pass
        try: os.kill(g.p8.pid, signal.SIGTERM)
        except: pass
        g.on = False
        try: loop.run_until_complete(on_end())
        except: pass
        reading_thread.join()
        writing_thread.join()
    else:
        print("Failed to start!")
        sys.exit(1)

if __name__ == "__main__": main()
