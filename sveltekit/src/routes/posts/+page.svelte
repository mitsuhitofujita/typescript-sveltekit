<script>
	/** @type {import('./$types').PageData} */
	export let data;
</script>

<svelte:head>
	<title>Posts</title>
</svelte:head>
<h1>Posts</h1>
{#if data.contents}
	<ul>
		{#each data.contents as content}
			<li>
				<a href="/posts/{content.id}/" sveltekit:prefetch>
					{content.title}
				</a>
			</li>
		{/each}
	</ul>
{/if}
