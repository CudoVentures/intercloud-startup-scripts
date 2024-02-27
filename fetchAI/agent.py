from uagents import Agent, Context
from requests import get

# fetches the public IP address of this VM
ipAddress = get('https://api.ipify.org').content.decode('utf8')

# creates the agent
helloWorld = Agent(
        name="hello-world",
        port=1234,
        # seed is secret phrase you should change
        seed="an example recovery phrase",
        endpoint=["http://" + ipAddress + ":1234/submit"],
        )

# sends a confirmation message once it starts running
@helloWorld.on_event("startup")
async def say_hello(ctx: Context):
    ctx.logger.info('Fetch.AI agent set up correctly.\n Hello from Intercloud!')

if __name__ == "__main__":
    helloWorld.run()
