#!/bin/bash

mkdir -p tag;
for tag in `grep -h '^tags:' _posts/* | sed 's/^tags://g;s/ /\n/g'`;do
	echo "---
layout: tag
title: ${tag}
tags: ${tag}
sitemap: false
---" > "tag/${tag}.html";
done;

