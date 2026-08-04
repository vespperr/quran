package com.dya.azadalkrd

import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.pdf.PdfRenderer
import android.os.Bundle
import android.os.ParcelFileDescriptor
import android.view.ViewGroup
import android.widget.ImageView
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager2.widget.ViewPager2
import java.io.File
/**
 * In-app PDF viewer using [PdfRenderer] (no Flutter pdfium). File must be readable locally.
 */
class PdfViewerActivity : AppCompatActivity() {

    private var renderer: PdfRenderer? = null
    private var pfd: ParcelFileDescriptor? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_pdf_viewer)

        val path = intent.getStringExtra(EXTRA_PATH) ?: run {
            finish()
            return
        }
        val title = intent.getStringExtra(EXTRA_TITLE) ?: "PDF"

        val toolbar = findViewById<Toolbar>(R.id.pdf_toolbar)
        setSupportActionBar(toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = title
        toolbar.setNavigationOnClickListener { finish() }

        val file = File(path)
        if (!file.isFile || !file.canRead()) {
            finish()
            return
        }

        try {
            pfd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
            renderer = PdfRenderer(pfd!!)
        } catch (_: Exception) {
            finish()
            return
        }

        val r = renderer!!
        val pageCount = r.pageCount
        val pager = findViewById<ViewPager2>(R.id.pdf_view_pager)
        val indicator = findViewById<android.widget.TextView>(R.id.pdf_page_indicator)

        pager.adapter = PdfPageAdapter(
            r,
            resources.displayMetrics.widthPixels,
            resources.displayMetrics.heightPixels,
        )
        pager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                indicator.text = "${position + 1} / $pageCount"
            }
        })
        indicator.text = if (pageCount > 0) "1 / $pageCount" else "0 / 0"
    }

    override fun onDestroy() {
        try {
            renderer?.close()
        } catch (_: Exception) {
        }
        renderer = null
        try {
            pfd?.close()
        } catch (_: Exception) {
        }
        pfd = null
        super.onDestroy()
    }

    private class PdfPageAdapter(
        private val pdfRenderer: PdfRenderer,
        private val screenW: Int,
        private val screenH: Int,
    ) : RecyclerView.Adapter<PdfPageAdapter.Holder>() {

        private val pageCount: Int = pdfRenderer.pageCount

        class Holder(val imageView: ImageView) : RecyclerView.ViewHolder(imageView)

        override fun onCreateViewHolder(parent: android.view.ViewGroup, viewType: Int): Holder {
            val iv = ImageView(parent.context).apply {
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                )
                scaleType = ImageView.ScaleType.FIT_CENTER
                adjustViewBounds = true
            }
            return Holder(iv)
        }

        override fun onBindViewHolder(holder: Holder, position: Int) {
            val page = pdfRenderer.openPage(position)
            try {
                val w = page.width
                val h = page.height
                val maxH = (screenH * 0.78f).toInt()
                val scale = minOf(screenW.toFloat() / w, maxH.toFloat() / h, 1f)
                val bw = (w * scale).toInt().coerceAtLeast(1)
                val bh = (h * scale).toInt().coerceAtLeast(1)
                val full = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
                page.render(full, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                val scaled = Bitmap.createScaledBitmap(full, bw, bh, true)
                if (full != scaled) {
                    full.recycle()
                }
                holder.imageView.setImageBitmap(scaled)
            } finally {
                page.close()
            }
        }

        override fun onViewRecycled(holder: Holder) {
            val d = holder.imageView.drawable
            if (d is BitmapDrawable) {
                d.bitmap?.recycle()
            }
            holder.imageView.setImageDrawable(null)
            super.onViewRecycled(holder)
        }

        override fun getItemCount(): Int = pageCount
    }

    companion object {
        const val EXTRA_PATH = "path"
        const val EXTRA_TITLE = "title"
    }
}
