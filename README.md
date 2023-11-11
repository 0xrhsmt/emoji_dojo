# Emoji Dojo

Dojo version of Emojimon.

https://github.com/latticexyz/emojimon

## Prerequisites

- Rust - install [here](https://www.rust-lang.org/tools/install)
- Cairo language server - install [here](https://book.dojoengine.org/development/setup.html#3-setup-cairo-vscode-extension)

## Step-by-Step Guide

Follow the steps below to setup and run your first Autonomous World.

### Step 1: Clone the Repository

Start by cloning the repository to your local machine. Open your terminal and type the following command:

```bash
git clone https://github.com/0xrhsmt/emoji_dojo.git
```

This command will create a local copy of the Emoji Dojor repository.

### Step 2: Install `dojoup`

The next step is to install `dojoup`. This cli tool is a critical component when building with dojo. It manages dependencies and helps in building your project. Run the following command in your terminal:

```bash
curl -L https://install.dojoengine.org | bash
```

The command downloads the `dojoup` installation script and executes it.

### Step 3: Test the Example World

With `dojoup` installed, you can now test your example world using the following command:

```bash
sozo test
```

Congratulations! You've successfully setup and deployed your first Dojo Autonomous World.

---

# Interacting With Your Local World

Explore and interact with your locally deployed world! This guide will help you fetch schemas, inspect entities, and execute actions using `sozo`.

If you have followed the example exactly and deployed on Katana you can use the following:

World address: **0xeb752067993e3e1903ba501267664b4ef2f1e40f629a17a0180367e4f68428**

Signer address: **0x06f62894bfd81d2e396ce266b2ad0f21e0668d604e5bb1077337b6d570a54aea**

## Fetching Component Schemas

Let's start by fetching the schema for the `Moves` component. Use the following command, replacing `<world-address>` with your world's address:

```bash
sozo component schema --world 0xeb752067993e3e1903ba501267664b4ef2f1e40f629a17a0180367e4f68428 Moves
```

You should get this in return:

```rust
struct Moves {
   remaining: u8
}
```
This structure indicates that the `Moves` component keeps track of the remaining moves as an 8-bit unsigned integer.

## Inspecting an Entity's Component

Let's check the remaining moves for an entity. In our examples, the entity is based on the caller address, so we'll use the address of the first Katana account as an example. Replace `<world-address>` and `<signer-address>` with your world's and entity's addresses respectively:

```bash
sozo component entity --world 0xeb752067993e3e1903ba501267664b4ef2f1e40f629a17a0180367e4f68428 Moves 0x06f62894bfd81d2e396ce266b2ad0f21e0668d604e5bb1077337b6d570a54aea
```

If you haven't made an entity yet, it will return `0`.

## Adding an Entity

No entity? No problem! You can add an entity to the world by executing the `Spawn` system. Remember, there's no need to pass any call data as the system uses the caller's address for the database. Replace `<world-address>` with your world's address:

```bash
sozo execute --world 0xeb752067993e3e1903ba501267664b4ef2f1e40f629a17a0180367e4f68428 Spawn
```

## Refetching an Entity's Component

After adding an entity, let's refetch the remaining moves with the same command we used earlier:

```bash
sozo component entity --world 0xeb752067993e3e1903ba501267664b4ef2f1e40f629a17a0180367e4f68428 Moves 0x06f62894bfd81d2e396ce266b2ad0f21e0668d604e5bb1077337b6d570a54aea
```

Congratulations! You now have `10` remaining moves! You've made it this far, keep up the momentum and keep exploring your world!


### Next steps:

Make sure to read the [Offical Dojo Book](https://book.dojoengine.org/index.html) for detailed instructions including theory and best practices.
